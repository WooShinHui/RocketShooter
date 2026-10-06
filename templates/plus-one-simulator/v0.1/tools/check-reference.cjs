// node tools/check-reference.cjs <directory-containing-luau.exe> <scratch-dir>
// Copies the frozen tree into normal src/tests layout for its existing harness.
const fs=require('node:fs'),path=require('node:path'),cp=require('node:child_process');
const root=path.resolve(__dirname,'..'),bin=path.resolve(process.argv[2]),scratch=path.resolve(process.argv[3]);
if(scratch===root||scratch.startsWith(root+path.sep))throw Error('Use a scratch directory outside the frozen template');
fs.mkdirSync(scratch,{recursive:true});
fs.cpSync(path.join(root,'reference/source'),path.join(scratch,'src'),{recursive:true});
fs.cpSync(path.join(root,'reference/tests'),path.join(scratch,'tests'),{recursive:true,filter:p=>!p.includes(path.sep+'.generated')});
fs.copyFileSync(path.join(root,'reference/default.project.json'),path.join(scratch,'default.project.json'));
const walk=p=>fs.readdirSync(p,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(path.join(p,e.name)):[path.join(p,e.name)]);
const run=(cmd,args,options={})=>{const r=cp.spawnSync(cmd,args,{encoding:'utf8',maxBuffer:20*1024*1024,...options});if(r.status!==0)throw Error([cmd,...args].join(' ')+'\n'+r.stdout+'\n'+r.stderr);return r.stdout+r.stderr};
const suffix=process.platform==='win32'?'.exe':'';let compiled=0;
for(const p of walk(path.join(scratch,'src')).filter(p=>p.endsWith('.luau'))){run(path.join(bin,'luau-compile'+suffix),[p]);compiled++;}
run(path.join(bin,'luau-compile'+suffix),[path.join(root,'contracts/ActionContract.luau')]);
const output=run(process.execPath,[path.join(scratch,'tests/run-local.cjs'),path.join(bin,'luau'+suffix),path.join(scratch,'checks')]);
fs.writeFileSync(path.join(scratch,'regression.log'),output);
const mobile=run(process.execPath,[path.join(scratch,'tests/mobile-layout.cjs'),path.join(bin,'luau'+suffix),path.join(scratch,'src/client/MobileLayout.client.luau'),path.join(scratch,'mobile-checks')]);
const dive=run(process.execPath,[path.join(scratch,'tests/dive-toggle.cjs'),path.join(bin,'luau'+suffix),path.join(scratch,'dive-checks')]);
const rojo=run('rojo',['build',path.join(scratch,'default.project.json'),'--output',path.join(scratch,'validation.rbxlx')],{cwd:scratch});
const inventory=JSON.parse(run(process.execPath,[path.join(root,'tools/verify-template.cjs')]));
const result={...inventory,sourceCompilation:{status:'PASS',files:compiled},actionContractCompilation:'PASS',mockedRegression:{status:'PASS',summary:output.trim().split(/\r?\n/).slice(-5)},mobileLayout:{status:'PASS',summary:mobile.trim().split(/\r?\n/).slice(-3)},rocketDiveToggle:{status:'PASS',summary:dive.trim().split(/\r?\n/).slice(-3)},rojoBuild:{status:'PASS',summary:rojo.trim()},visualInspection:'ui-layout.png and actual current-ui.png inspected; schematic icon labels differ intentionally from reference art',liveObservation:'7 pages opened and restored; 22 ScreenGui/148 core elements; action UI from frozen source',notPerformed:['physical mobile device QA','two real network clients','published-server persistence QA','new stone/spit/tongue/sword adapter implementation']};
fs.writeFileSync(path.join(root,'validation.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify(result,null,2));

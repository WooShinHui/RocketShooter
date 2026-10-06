// Verify reference integrity and all first-party spec links; no live mutation.
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'..'),m=JSON.parse(fs.readFileSync(path.join(root,'manifest.json'),'utf8'));
const hash=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
for(const r of m.references){const p=path.resolve(root,r.path);if(!p.startsWith(root+path.sep))throw Error('Path escapes template');if(!fs.existsSync(p)||hash(p)!==r.sha256)throw Error('Reference changed: '+r.path);}
const required=['README.md','AGENTS.md','UI_LAYOUT.md','LIFECYCLE.md','ECONOMY.md','EVENTS_AND_DATA.md','ACTION_ADAPTER.md','REUSE_AND_ACCEPTANCE.md','STATUS.md','SOURCE_INDEX.md','API_INVENTORY.md','ASSETS.md','ui-layout.png','ui-layout.svg','reference/ui-runtime.json','reference/ui-pages.json','reference/scene-checkpoint.rbxl','contracts/ActionContract.luau'];
for(const r of required)if(!fs.existsSync(path.join(root,r)))throw Error('Missing '+r);
let links=0;for(const name of fs.readdirSync(root).filter(n=>n.endsWith('.md'))){const s=fs.readFileSync(path.join(root,name),'utf8');for(const match of s.matchAll(/\]\(([^)]+)\)/g)){const target=match[1].split('#')[0];if(!target||/^(https?:|mailto:)/.test(target))continue;const p=path.resolve(root,target);if(!fs.existsSync(p))throw Error(`Broken link: ${name} -> ${target}`);links++;}}
const ui=JSON.parse(fs.readFileSync(path.join(root,'reference/ui-runtime.json'),'utf8').replace(/^\uFEFF/,''));
const page=JSON.parse(fs.readFileSync(path.join(root,'reference/ui-pages.json'),'utf8').replace(/^\uFEFF/,''));
if(ui.screens.length!==22||ui.elements.length!==148||Object.keys(page).length!==7)throw Error('Incomplete UI captures');
for(const key of ['Store','Food','World','Guide','Settings','Rebirth','Trails'])if(!page[key]?.elements.length)throw Error('Missing page '+key);
const png=fs.readFileSync(path.join(root,'ui-layout.png'));if(png.subarray(0,8).toString('hex')!=='89504e470d0a1a0a')throw Error('Not a PNG');
const result={verifiedAt:new Date().toISOString(),references:m.references.length,sourceFiles:m.sourceFiles,links,uiScreens:ui.screens.length,coreUIElements:ui.elements.length,pages:Object.keys(page).length,referenceHashes:'PASS',linksAndRequiredFiles:'PASS',imageSignature:'PASS'};
console.log(JSON.stringify(result,null,2));

-- Set Style="Brick" for an art-only rollback. Shared altitude palettes for butter/dumplings.
local palettes={
 {Min=0,Colors={{255,225,123},{255,159,166},{151,231,188}}},
 {Min=670,Colors={{104,218,255},{116,241,208},{255,226,118}}},
 {Min=4800,Colors={{218,244,255},{126,195,255},{160,239,235}}},
 {Min=12500,Colors={{195,143,255},{245,155,227},{160,149,255}}},
 {Min=28000,Colors={{100,181,236},{129,148,255},{213,242,255}}},
 {Min=60000,Colors={{255,171,97},{255,121,128},{255,214,125}}},
 {Min=110000,Colors={{118,242,236},{161,255,163},{185,127,255}}},
 {Min=185000,Colors={{170,153,245},{118,160,255},{218,227,255}}},
 {Min=300000,Colors={{240,119,216},{99,156,255},{240,239,255}}},
}
local C={Style="Butter",Mesh="rbxassetid://83573042900595",MeshSize={13.746269226074219,4.7512640953063965,6.334031581878662},Face="rbxassetid://91818640034843",
 Dumpling={Mesh="rbxassetid://110356585242168",MeshSize={934.7799072265625,637.9940185546875,935.469970703125},Face="rbxassetid://85735925995041"},Palettes=palettes}
function C.Color(height,index)
 local selected=palettes[1];for _,p in palettes do if height>=p.Min then selected=p end end
 local colors=selected.Colors;return Color3.fromRGB(table.unpack(colors[(index-1)%#colors+1]))
end
return table.freeze(C)

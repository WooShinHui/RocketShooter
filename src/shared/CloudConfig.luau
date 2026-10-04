-- Altitudes are studs above the shared Ground datum, never absolute World Y.
return table.freeze({
	FormatAltitude = function(value) return if value>=1000 then string.format("%.1f km",value/1000) else string.format("%d m",math.max(0,math.floor(value))) end,
    HeightPresentation = table.freeze({GroundY=0, Enter={260,3500,100000}, Hysteresis=8, TransitionSeconds=.65,
        Names={"초원 위 하늘","구름 지대","높은 하늘","우주 지대"},
        Biomes={
            {Min=0,Name="초원 · 산맥",Kind="Meadow",Color={108,176,106},Rock={92,123,141},Spacing=160},
            {Min=260,Name="구름 바다 · 떠 있는 초원",Kind="Cloud",Color={163,230,199},Rock={126,159,171},Spacing=220},
            {Min=850,Name="설산 · 얼음 봉우리",Kind="Snow",Color={224,246,255},Rock={99,155,192},Spacing=500},
            {Min=3500,Name="수정 군도 · 보랏빛 하늘",Kind="Crystal",Color={195,143,255},Rock={77,62,121},Spacing=900},
            {Min=16000,Name="폭풍층 · 푸른 번개",Kind="Storm",Color={100,181,236},Rock={45,65,97},Spacing=2200},
            {Min=40000,Name="상층 대기 · 붉은 암석",Kind="Ember",Color={255,171,97},Rock={151,77,65},Spacing=3600},
            {Min=70000,Name="우주 경계 · 궤도 구조물",Kind="Orbit",Color={118,242,236},Rock={64,86,111},Spacing=4000},
            {Min=100000,Name="우주 · 소행성 지대",Kind="Space",Color={170,153,245},Rock={78,72,105},Spacing=5000},
        }, Milestones={260,500,1500,3500,10000,20000,40000,70000,100000,140000}}),
    EnterAltitude = 180, LeaveAltitude = 165, NoticeSeconds = 4,
	Geometry = table.freeze({Spacing = 240, Offset = 65, HeightVariation = 18,
		Banks = {
			{Key = "Cloud.Wisp", Lateral = -250, Altitude = 152, ForwardOffset = 50},
			{Key = "Cloud.Bank", Lateral = 240, Altitude = 198, ForwardOffset = 0},
			{Key = "Cloud.Bank", Lateral = -130, Altitude = 218, ForwardOffset = 85},
		}}),
	Ground = table.freeze({Brightness = 2, Exposure = 0, Density = 0.18, Haze = 0,
		FogEnd = 100000, Ambient = {130, 140, 155}, Outdoor = {150, 155, 165}}),
	Clouds = table.freeze({Brightness = 2.6, Exposure = 0.15, Density = 0.25, Haze = 1,
		FogEnd = 6500, Ambient = {180, 195, 215}, Outdoor = {205, 215, 230}}),
})

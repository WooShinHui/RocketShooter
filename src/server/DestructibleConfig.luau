-- 이번 테스트의 점수는 메모리 전용이며 경제·저장 시스템과 연결하지 않습니다.
local Config = {
	PreviewPitch = 45, PreviewPower = 1, PreviewTiming = 1,
	CascadeInterval = 0.07,
	Types = {
		Rock = {DisplayName = "암석", RunScore = 10},
		FloatingIsland = {DisplayName = "부유섬", RunScore = 30},
		Ruin = {DisplayName = "폐허", RunScore = 50},
	},
	-- 같은 전방 지점의 두 타깃은 동시에 관통할 수 없도록 좌우로 분리합니다.
	Choices = {
		{Type = "Rock", Pitch = 45, Yaw = 0, Time = 0.65, Lateral = 0, Choice = 1},
		{Type = "FloatingIsland", Pitch = 45, Yaw = 0, Time = 0.65, Lateral = 16, Choice = 1},
		{Type = "Rock", Pitch = 45, Yaw = 0, Time = 1.25, Lateral = 0, Choice = 2},
		{Type = "Ruin", Pitch = 45, Yaw = 0, Time = 1.25, Lateral = 26, Choice = 2},
		-- Authored low-left / medium-right routes use different initial aims.
		{Type = "Rock", Pitch = 30, Yaw = 22, Time = 0.50, Lateral = 0, Choice = 3},
		{Type = "Ruin", Pitch = 30, Yaw = 22, Time = 1.00, Lateral = -26, Choice = 3},
		{Type = "Rock", Pitch = 35, Yaw = -22, Time = 0.50, Lateral = 0, Choice = 4},
		{Type = "FloatingIsland", Pitch = 35, Yaw = -22, Time = 1.00, Lateral = 26, Choice = 4},
	},
}

-- 대포·현재 launch 수식·Gravity에서 계산한 고정 참조 궤적입니다. 실제 비행은 수정하지 않습니다.
function Config.Placements(origin, velocity, right, gravity, referenceFor)
	local result = {}
	for id, choice in Config.Choices do
		local start, launch, side = origin, velocity, right
		if referenceFor then start, launch, side = referenceFor(choice.Yaw, choice.Pitch) end
		local t = choice.Time
		table.insert(result, {Id = id, Type = choice.Type, Choice = choice.Choice,
			Center = start + launch * t - Vector3.new(0, gravity * t * t / 2, 0)
				+ side * choice.Lateral})
	end
	return result
end

-- 셀마다 실루엣과 재질을 정의합니다. 배치·형상에 난수를 사용하지 않습니다.
function Config.Cells(kind)
	if kind == "FloatingIsland" then
		return {
			{Class = "Part", Size = Vector3.new(9, 3, 9), Offset = Vector3.new(0, 6, 0), Material = "Grass", Color = {82, 139, 66}},
			{Class = "Part", Size = Vector3.new(8, 7, 8), Offset = Vector3.new(0, 1, 0), Material = "Ground", Color = {115, 83, 57}},
			{Class = "WedgePart", Size = Vector3.new(7, 8, 7), Offset = Vector3.new(0, -6, 0), Material = "Rock", Color = {108, 100, 81}},
			{Class = "CornerWedgePart", Size = Vector3.new(5, 6, 5), Offset = Vector3.new(0, -12, 0), Material = "Rock", Color = {89, 85, 75}},
		}
	elseif kind == "Ruin" then
		return {
			{Class = "Part", Size = Vector3.new(10, 3, 8), Offset = Vector3.new(0, -13, 0), Material = "Concrete", Color = {166, 158, 134}},
			{Class = "Part", Size = Vector3.new(3, 27, 6), Offset = Vector3.new(-3.5, 2, 0), Material = "Limestone", Color = {198, 185, 153}},
			{Class = "Part", Size = Vector3.new(3, 22, 6), Offset = Vector3.new(3.5, 0, 0), Material = "Limestone", Color = {180, 171, 148}},
			{Class = "Part", Size = Vector3.new(10, 4, 6), Offset = Vector3.new(0, 15, 0), Material = "Concrete", Color = {209, 195, 165}},
			{Class = "WedgePart", Size = Vector3.new(5, 5, 6), Offset = Vector3.new(2, 20, 0), Material = "Slate", Color = {153, 145, 128}},
			-- 파괴 타깃의 중심은 열린 아치 구멍이 아니라 부서진 석재 연결부입니다.
			{Class = "Part", Size = Vector3.new(10, 5, 6), Offset = Vector3.zero, Material = "Concrete", Color = {180, 171, 148}},
		}
	end
	return {
		{Class = "Part", Size = Vector3.new(8, 13, 9), Offset = Vector3.zero, Material = "Rock", Color = {112, 105, 91}},
		{Class = "WedgePart", Size = Vector3.new(7, 7, 8), Offset = Vector3.new(0, 8, 0), Material = "Slate", Color = {96, 100, 101}},
		{Class = "CornerWedgePart", Size = Vector3.new(7, 7, 8), Offset = Vector3.new(0, -8, 0), Material = "Rock", Color = {128, 119, 103}},
	}
end

-- 서버의 실제 접촉 부위 위치/크기로 재확인합니다. 액세서리는 Spawner에서 제외합니다.
function Config.Contains(part, position, contactRadius)
	local p = part.CFrame:PointToObjectSpace(position)
	local radius = contactRadius or 0
	local extent = part.Size / 2 + Vector3.new(2 + radius, 3 + radius, 2 + radius)
	return math.abs(p.X) <= extent.X and math.abs(p.Y) <= extent.Y and math.abs(p.Z) <= extent.Z
end

for _, definition in Config.Types do table.freeze(definition) end
for _, choice in Config.Choices do table.freeze(choice) end
table.freeze(Config.Types)
table.freeze(Config.Choices)
return table.freeze(Config)

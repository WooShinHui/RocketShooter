do
 local V=environment().Vector3
 check(ShowroomConfig.Near(V.new(0,3,5.9),false),"raised unlocked toilet approach remains inside the auto-seat zone")
 check(not ShowroomConfig.Near(V.new(6,3,6),false),"auto-seat uses a radial approach rather than a wide diagonal box")
 check(not ShowroomConfig.Near(V.new(0,9,0),false),"another floor above the toilet cannot auto-seat")
 check(not ShowroomConfig.Near(V.new(0,-3,0),false),"below-deck players cannot auto-seat through the floor")
 check(ShowroomConfig.Near(V.new(0,3,8),true)and not ShowroomConfig.Near(V.new(0,3,9.1),true),"exit zone requires leaving beyond the seating radius before automatic re-entry")
 check(ShowroomConfig.Near(V.new(0,20,0),true),"jumping vertically cannot clear the automatic re-seat block")
end

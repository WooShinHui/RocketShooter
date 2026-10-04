do
 local camera={ViewportSize={X=1280,Y=720},point={X=640,Y=360,Z=24},onScreen=true}
 function camera:WorldToViewportPoint(_)return self.point,self.onScreen end
 local x,y=XPProjection.Calculate(camera,{},0)
 check(x==640 and y==360,"head popup starts at its real projected position")
 local _,raised=XPProjection.Calculate(camera,{},.9)
 check(raised==338,"XP animation rises from the head position")
 camera.point={X=20,Y=15,Z=24}
 check(XPProjection.Calculate(camera,{},0)==nil,"clipped top-left popup cannot leave an XP fragment in the corner")
 for _,p in {{X=1270,Y=360,Z=24},{X=640,Y=715,Z=24},{X=640,Y=15,Z=24},{X=640,Y=360,Z=-24},{X=0/0,Y=360,Z=24}}do
  camera.point=p;check(XPProjection.Calculate(camera,{},0)==nil,"edge, behind-camera and invalid projections remain hidden")
 end
 camera.point={X=640,Y=360,Z=24};camera.onScreen=false
 check(XPProjection.Calculate(camera,{},0)==nil,"off-screen head never defaults to the screen origin")
 camera.onScreen=true;camera.ViewportSize={X=0,Y=0}
 check(XPProjection.Calculate(camera,{},0)==nil and XPProjection.Calculate(nil,{},0)==nil,"camera initialization cannot display a default-position label")
end

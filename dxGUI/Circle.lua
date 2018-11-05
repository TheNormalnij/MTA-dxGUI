dxGUI.baseClass:subclass{
	type  = 'circle';
	color = 0xFF000000;
	angleStart = 0;
	borderWidth = 1e9;
	postGUI = false;

	create = function( self )
		local angleSweep = self.angleSweep or math.pi * 2 - self.angleStart
		if ( angleSweep < math.pi * 2 ) then
			self.angleEnd = math.fmod( self.angleStart + angleSweep, math.pi * 2 )
		else
			self.angleStart = 0
			self.angleEnd = math.pi * 2
		end

		if not dxGUI.circle.circleShader then
			dxGUI.circle.circleShader = dxCreateShader( 'dxGUI/shaders/circle.fx' )
		end
		return self
	end;

	setAngleSweep = function( self, angleSweep )
		if ( angleSweep < math.pi * 2 ) then
			self.angleEnd = math.fmod( self.angleStart + angleSweep, math.pi * 2 )
		else
			self.angleStart = 0
			self.angleEnd = math.pi * 2
		end
	end;

	draw = function( self )
		local circleShader = self.circleShader
		dxSetShaderValue( circleShader, 'sCircleWidthInPixel', self.w );
		dxSetShaderValue( circleShader, 'sCircleHeightInPixel', self.h );
		dxSetShaderValue( circleShader, 'sBorderWidthInPixel', self.borderWidth );
		dxSetShaderValue( circleShader, 'sAngleStart', self.angleStart - math.pi );
		dxSetShaderValue( circleShader, 'sAngleEnd', self.angleEnd - math.pi );
		dxDrawImage( self.x, self.y, self.w, self.h, self.circleShader, 0, 0, 0, self.color, self.postGUI )
	end;

	setPostGUI = function( self, state )
		if state == true or state == false then
			self.postGUI = state
		end
	end;
}
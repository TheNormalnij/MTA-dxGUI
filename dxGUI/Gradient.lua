local shader

dxGUI.baseClass:subclass{
	type                  = 'gradient';
	colorFrom             = tocolor( 255, 255, 255 );
	colorTo               = tocolor( 0, 0, 0 );
	isHorizontal          = false;
	easing                = 'Linear';

	rotation = 0;
	rotationCenterOffsetX = 0;
	rotationCenterOffsetY = 0;
	color = 0xFFFFFFFF;

	create = function( self )
		if not self.gradientFunction and not self.shader then
			if not shader then
				shader = dxCreateShader( "dxGUI/shaders/gradient.fx" )
			end

			self.shader = shader
		end

		return self
	end;

	-- gradientFunction = function( self, progress )
	-- 	local from = self.fromRGB
	-- 	local to = self.toRGB
	-- 	if not from or not to then
	-- 		from = { color.HEXtoRGB( self.colorFrom ) }
	-- 		to = { color.HEXtoRGB( self.colorTo ) }
	-- 		self.fromRGB = from
	-- 		self.toRGB = to
	-- 	end
	-- 	progress = getEasingValue( progress, self.easing )

	-- 	return tocolor( from[1] + ( to[1] - from[1] ) * progress,
	-- 		from[2] + ( to[2] - from[2] ) * progress,
	-- 		from[3] + ( to[3] - from[3] ) * progress,
	-- 		from[4] + ( to[4] - from[4] ) * progress
	-- 	)
	-- end;

	setGradientFunction = function( self, func )
		if func then
			self.gradientFunction = func
			self.shader = nil
		else
			if not shader then
				shader = dxCreateShader( "dxGUI/shaders/gradient.fx" )
			end

			self.shader = shader		
		end
	end;

	draw = function( self )
		if self.shader then
			if self.isHorizontal then
				self.shader:setValue( 'gradientVector', 1, 0 )
			else
				self.shader:setValue( 'gradientVector', 0, 1 )
			end
			local r, g, b, a = color.HEXtoRGB( self.colorFrom )
			self.shader:setValue( 'sGradientFromColor', r / 255, g / 255, b / 255, a / 255 )
			r, g, b, a = color.HEXtoRGB( self.colorTo )
			self.shader:setValue( 'sGradientToColor', r / 255, g / 255, b / 255, a / 255 )
			dxDrawImage( self.x, self.y, self.w, self.h, self.shader, self.rotation,
				self.rotationCenterOffsetX,	self.rotationCenterOffsetY, self.color, self.postGUI )
		else
			if self.isHorizontal then
				for x = 0, self.w -1 do
					dxDrawRectangle( self.x + x, self.y, 1, self.h, self:gradientFunction( (x+1) / self.w ), self.postGUI )
				end
			else
				for y = 0, self.h -1 do
					dxDrawRectangle( self.x, self.y + y, self.w, 1, self:gradientFunction( (y+1) / self.h ), self.postGUI )
				end
			end
		end
	end;
}

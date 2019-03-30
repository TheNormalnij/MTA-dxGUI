dxConstruction:subclass{
	type  = 'slider';
	direction = false; -- false = horizontal; true = vertical
	resize = false;
	deadZone = 0;

	create = function( self )
		if not dxConstruction.create( self, false ) then
			return false
		end

		self:setProgress( self.progress or 0.5 )
		self.input = Input:create{ }		
		return self
	end;

	setProgress = function( self, progress )
		if progress and progress >= 0 and progress <= 1 then
			progress = math.min( 1, math.max( progress, 0 ) )
			self.progress = progress
			local slider = self.objects.slider
			local bar = self.objects.bar or self

			if self.resize and self.list then
				if self.direction then
					slider:setSize( slider.w, 1 / ( itemsCount - math.ceil( self.list.h / self.list.construction.h ) + 1 ) * bar.h )
				else
					slider:setSize( 1 / ( itemsCount - math.ceil( self.list.w / self.list.construction.w ) + 1 ) * bar.h, slider.h  )
				end
			end

			if self.direction then
				slider:setPosition( slider.x, bar.y + ( 1 - self.deadZone ) * bar.h * progress + bar.h * self.deadZone / 2 )
			else
				slider:setPosition( bar.x + ( 1 - self.deadZone ) * bar.w * progress + bar.w * self.deadZone / 2 - slider.w / 2, slider.y )
			end

			if self.onChangeProgress then
				self:onChangeProgress( progress )
			end
		end
	end;

	getProgress = function( self )
		return self.progress
	end;

	onClick = function( self, button, state, cX, cY )
		local bar = self.objects.bar
		if self.direction then
			self:setProgress( math.max( 0, math.min( 1, ( cY - bar.y - bar.h * self.deadZone / 2 ) / ( bar.h - bar.h * self.deadZone ) ) ) )
		else
			self:setProgress( math.max( 0, math.min( 1, ( cX - bar.x - bar.w * self.deadZone / 2 ) / ( bar.w - bar.w * self.deadZone ) ) ) )
		end
	end;

	onCursorMove = function( self, inBox, cX, cY )
		if getKeyState( 'mouse1' ) then
			local bar = self.objects.bar
			if self.direction then
				self:setProgress( math.max( 0, math.min( 1, ( cY - bar.y - bar.h * self.deadZone / 2 ) / ( bar.h - bar.h * self.deadZone ) ) ) )
			else
				self:setProgress( math.max( 0, math.min( 1, ( cX - bar.x - bar.w * self.deadZone / 2 ) / ( bar.w - bar.w * self.deadZone ) ) ) )
			end
		end
	end;

	attachList = function( self, list )
		if self.list then
			for id, anim in pairs( self.anims ) do
				if anim.name == 'slider-list-sync' then
					self:removeAnim( id )
					break
				end
			end
			self.list = list
		end
		if list then
			local anim = Anim.find( 'slider-list-sync' )
			self:addAnim( anim, list )
		end
	end;
}

Anim{
	name = 'slider-list-sync';

	create = function( self, gui, list )
		self.list = list
		gui.onChangeProgress = function( gui, progress )
			local maxOffsetY = list.maxHorizontalItems and ( math.ceil( #list.items / list.maxHorizontalItems ) * list.construction.h - list.h ) or 0
			self.list.offsetY = maxOffsetY * progress
		end
		return self
	end;

	update = function( self, gui )
		local list = self.list
		local maxOffsetY = list.maxHorizontalItems and ( math.ceil( #list.items / list.maxHorizontalItems ) * list.construction.h - list.h ) or 0
		local onChange = self.onChangeProgress
		self.onChangeProgress = nil
		if maxOffsetY > 0 then
			gui:setProgress( list.offsetY / maxOffsetY )
		else
			gui:setProgress( 0 )
		end
		self.onChangeProgress = onChange
		return true
	end;
}

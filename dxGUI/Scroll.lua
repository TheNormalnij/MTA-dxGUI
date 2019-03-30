dxConstruction:subclass{
	type  = 'scroll_vertical';
	resize = false;

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
			local itemsCount = self.list and #self.list.items
			if self.resize and itemsCount and itemsCount - math.ceil( self.list.h / self.list.construction.h ) >= 1 then
				slider:setSize( slider.w, 1 / ( itemsCount - math.ceil( self.list.h / self.list.construction.h ) + 1 ) * bar.h )
			else
				--slider.h = bar.h
			end
			slider:setPosition( bar.x, self.y + ( bar.h - slider.h ) * progress )
		end
	end;

	attachList = function( self, list )
		if list then
			self.list = list
			local anim = Anim.find( 'scroll-sync' )
			self:addAnim( anim )
		end
	end;

	_onClick = function( self, button, state, cX, cY )
		local bar = self.objects.bar or self
		self:setProgress( ( cX - bar.x ) / bar.w )
	end;

	onCursorMove = function( self, inBox, cX, cY )
		if inBox and getKeyState( 'mouse1' ) then
			local bar = self.objects.bar or self
			self:setProgress( ( cX - bar.x ) / bar.w )
		end
	end;
}

Anim{
	name = 'scroll-sync';

	create = function( self, gui )
		return self
	end;

	update = function( self, gui )
		local list = gui.list
		local maxOffsetY = list.maxHorizontalItems and ( math.ceil( #list.items / list.maxHorizontalItems ) * list.construction.h - list.h ) or 0
		gui:setProgress( gui.list.offsetY / maxOffsetY )
		return true
	end;
}
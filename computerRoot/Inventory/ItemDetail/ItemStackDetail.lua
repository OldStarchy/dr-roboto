ItemStackDetail = Class(ItemDetail)
ItemStackDetail.ClassName = 'ItemStackDetail'

function ItemStackDetail:constructor()
	error("Can't construct items manually", 3)
end

function ItemStackDetail:conversionConstructor()
	self.metadata = self.damage
end

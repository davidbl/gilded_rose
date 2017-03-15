BACKSTAGE_PASS = 'Backstage passes to a TAFKAL80ETC concert'
AGED_BRIE = 'Aged Brie'
SULFURAS = 'Sulfuras, Hand of Ragnaros'
CONJURED_MANA_CAKE = "Conjured Mana Cake"

class Updateable
  MAX_QUALITY = 50
  MIN_QUALITY = 0

  def initialize(item)
    @item = item
  end

  def update(step)
    adjust_quality(step)
    decrement_sell_in {adjust_quality(step)}
  end

  private

  def sell_in
    @item.sell_in
  end

  def adjust_quality(step)
    clamp_quality(@item.quality + step)
  end

  def zero_quality
    @item.quality = 0
  end

  def decrement_sell_in(&block)
    @item.sell_in -= 1
    block.call if expired?
  end

  def expired?
    @item.sell_in < 0
  end

  def clamp_quality(x)
    @item.quality = [[x, MAX_QUALITY].min, MIN_QUALITY].max
  end
end

class Normal < Updateable
  def update
    super(-1)
  end
end

class Legendary < Updateable
  def update
    #noop
  end
end

class AgedBrie < Updateable
  def update
    super(1)
  end
end

class BackstagePass < Updateable
  def update
    case sell_in
    when 1..5
      adjust_quality(3)
    when 6..10
      adjust_quality(2)
    else
      adjust_quality(1)
    end
    decrement_sell_in {zero_quality}
  end
end

class Conjured < Updateable
  def update
    super(-2)
  end
end

def update_quality(items)
  klass_map = {
    AGED_BRIE => AgedBrie,
    BACKSTAGE_PASS => BackstagePass,
    CONJURED_MANA_CAKE => Conjured,
    SULFURAS => Legendary
  }
  klass_map.default = Normal
  items.each do |item|
    klass_map[item.name].new(item).update
  end
end

# DO NOT CHANGE THINGS BELOW -----------------------------------------

Item = Struct.new(:name, :sell_in, :quality)

# We use the setup in the spec rather than the following for testing.
#
# Items = [
#   Item.new("+5 Dexterity Vest", 10, 20),
#   Item.new("Aged Brie", 2, 0),
#   Item.new("Elixir of the Mongoose", 5, 7),
#   Item.new("Sulfuras, Hand of Ragnaros", 0, 80),
#   Item.new("Backstage passes to a TAFKAL80ETC concert", 15, 20),
#   Item.new("Conjured Mana Cake", 3, 6),
# ]


BACKSTAGE_PASS = 'Backstage passes to a TAFKAL80ETC concert'
AGED_BRIE = 'Aged Brie'
SULFURAS = 'Sulfuras, Hand of Ragnaros'
CONJURED_MANA_CAKE = "Conjured Mana Cake"

class PersishableItem
  def initialize(item, max_quality = 50, min_quality=0)
    @max_quality = max_quality
    @min_quality = min_quality
    @item = item
  end

  def update(quality_step, sell_in_step = -1)
    adjust_quality(quality_step)
    adjust_sell_in(sell_in_step) {adjust_quality(quality_step)}
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

  def adjust_sell_in(step, &block)
    @item.sell_in += step
    block.call if expired?
  end

  def expired?
    @item.sell_in < 0
  end

  def clamp_quality(x)
    @item.quality = [@min_quality, x, @max_quality].sort[1]
  end
end

class NormalItem < PersishableItem
  def update
    super(-1)
  end
end

class LegendaryItem < PersishableItem
  def update
    @max_quality = 80
    super(0,0)
  end
end

class AgedBrie < PersishableItem
  def update
    super(1)
  end
end

class BackstagePass < PersishableItem
  def update
    case sell_in
    when 1..5
      adjust_quality(3)
    when 6..10
      adjust_quality(2)
    else
      adjust_quality(1)
    end
    adjust_sell_in(-1) {zero_quality}
  end
end

class ConjuredItem < PersishableItem
  def update
    super(-2)
  end
end

def update_quality(items)
  klass_map = {
    AGED_BRIE => AgedBrie,
    BACKSTAGE_PASS => BackstagePass,
    CONJURED_MANA_CAKE => ConjuredItem,
    SULFURAS => LegendaryItem
  }
  klass_map.default = NormalItem
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


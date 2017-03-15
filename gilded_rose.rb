BACKSTAGE_PASS = 'Backstage passes to a TAFKAL80ETC concert'
AGED_BRIE = 'Aged Brie'
SULFURAS = 'Sulfuras, Hand of Ragnaros'
CONJURED_MANA_CAKE = "Conjured Mana Cake"

class Updateable
  MAX_QUALITY = 50
  MIN_QUALITY = 0
  attr_accessor :item
  def self.new_from_item(item)
    self.new item
  end

  def initialize(item)
    @item = item
  end

  def sell_in
    @item.sell_in
  end

  def update
  end

  def decrement_quality(step=1)
    @item.quality = [MIN_QUALITY, @item.quality - step].max
  end

  def increment_quality(step=1)
    @item.quality = [MAX_QUALITY, @item.quality + step].min
  end

  def zero_quality
    @item.quality = 0
  end

  def decrement_sell_in(&block)
    @item.sell_in -= 1
    block.call if expired? && block_given?
  end

  def expired?
    @item.sell_in < 0
  end
end

class Normal < Updateable
  def update
    decrement_quality
    decrement_sell_in {decrement_quality}
  end
end

class AgedBrie < Updateable
  def update
    increment_quality
    decrement_sell_in {increment_quality}
  end
end

class BackstagePass < Updateable
  def update
    case self.sell_in
    when 1..5
      increment_quality(3)
    when 6..10
      increment_quality(2)
    else
      increment_quality(1)
    end
    decrement_sell_in {zero_quality}
  end
end

class Conjured < Updateable
  def update
    decrement_quality(2)
    decrement_sell_in{decrement_quality(2)}
  end
end

def update_quality(items)
  klass_map = {
    AGED_BRIE => AgedBrie,
    BACKSTAGE_PASS => BackstagePass,
    CONJURED_MANA_CAKE => Conjured,
    SULFURAS => Updateable
  }
  klass_map.default = Normal
  items.each do |item|
    klass_map[item.name].new_from_item(item).update
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


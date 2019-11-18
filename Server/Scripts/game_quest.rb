#==============================================================================
# ** Game_Quest
#------------------------------------------------------------------------------
#  Esta classe lida com a missão.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Game_Quest

  attr_reader   :switch_id
  attr_reader   :item_id
  attr_reader   :item_kind
  attr_reader   :item_amount
  attr_reader   :enemy_id
  attr_reader   :max_kills
  attr_reader   :reward
  attr_accessor :state
  attr_accessor :kills

  def initialize(id, state, kills)
    @state = state
    @kills = kills
    @switch_id = Quests::DATA[id][2]
    @item_id = Quests::DATA[id][3]
    @item_kind = Quests::DATA[id][4]
    @item_amount = Quests::DATA[id][5]
    @enemy_id = Quests::DATA[id][6]
    @max_kills = Quests::DATA[id][7]
    @reward = Reward.new
    @reward.item_id = Quests::DATA[id][9]
    @reward.item_kind = Quests::DATA[id][10]
    @reward.item_amount = Quests::DATA[id][11]
    @reward.exp = Quests::DATA[id][8]
    @reward.gold = Quests::DATA[id][12]
    @repeat = Quests::DATA[id][13]
  end

  def in_progress?
    @state == Constants::QUEST_IN_PROGRESS
  end

  def finished?
    @state == Constants::QUEST_FINISHED
  end

  def repeat?
    @repeat
  end
  
end

SMODS.Atlas {
    key = "T.Jokers",
    path = "Jokers.png",
    px = 71,
    py = 95,
}
SMODS.Joker {
    key = "blue_java",
    loc_txt =  	{
        name = 'Blue Java',
        text = {
            "{C:chips}+#1#{} chips",
            "{C:green}0{} in 1 chance this",
            "card is destroyed",
            "at end of round"
        },
    },

    yes_pool_flag = 'gros_michel_extinct',
    config = { extra = { chips = 200 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips } }
      end,
    -- Sets rarity. 1 common, 2 uncommon, 3 rare, 4 legendary.
    rarity = 2,
    -- Which atlas key to pull from.
    atlas = 'T.Jokers',
    -- This card's position on the atlas, starting at {x=0,y=0} for the very top left.
    pos = { x = 0, y = 0 },
    -- Cost of card in shop.
    cost = 4,
    calculate = function(self, card, context)
    -- Tests if context.joker_main == true.
    -- joker_main is a SMODS specific thing, and is where the effects of jokers that just give +stuff in the joker area area triggered, like Joker giving +Mult, Cavendish giving XMult, and Bull giving +Chips.
      if context.joker_main then
      -- Tells the joker what to do. In this case, it pulls the value of mult from the config, and tells the joker to use that variable as the "mult_mod".
        return {
          chip_mod = card.ability.extra.chips,
          message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra.chips } }
        }
      end
    end
}

SMODS.Joker {
  key = 'mint',
  loc_txt =	  {
    name = 'Mint Condition',
    text = {
      "Earn {C:money}$#1#{} at end of round",
      "and reduce this by {C:mult}#2#{}"
    }
  },

  config = { extra = { money = 7, money_decrease = 1 } },
  rarity = 2,
  atlas = 'T.Jokers',
  pos = { x = 1, y = 0 },
  cost = 8,
  eternal_compat = false,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.money, card.ability.extra.money_decrease } }
  end,

  calc_dollar_bonus = function(self, card)
    local bonus = card.ability.extra.money
    if bonus > 0 then return bonus end
  end,

  calculate = function(self, card, context)
    if context.end_of_round and not context.repetition and context.game_over == false and not context.blueprint then
      card.ability.extra.money = card.ability.extra.money - card.ability.extra.money_decrease
      if card.ability.extra.money <= 0 then
        G.E_MANAGER:add_event(Event({
          func = function()
          play_sound('tarot1')
          card.T.r = -0.2
          card:juice_up(0.3, 0.4)
          card.states.drag.is = true
          card.children.center.pinch.x = true
          G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
        func = function()
          G.jokers:remove_card(card)
              card:remove()
              card = nil
              return true
        end
          }))
          return true
        end
      }))
      return {
        message = localize('k_eaten_ex'),
        colour = G.C.RED,
      }
    else
      return {
        message = '-$1',
        colour = G.C.GOLD,
      }
      end
    end
  end
}

SMODS.Joker {
  key = 'chroma',
  loc_txt = {
    name = 'Chromatic Aberration',
    text = {
      "Scored {C:attention}Wild Cards{} become {C:dark_edition}Polychrome{}"
    }
  },
  rarity = 3,
  atlas = 'T.Jokers',
  pos = { x = 2, y = 0 },
  soul_pos = { x = 3, y = 0 },
  cost = 9,
  calculate = function(self, card, context)
    if context.before and not context.blueprint then
      local wilds = {}
      for k, v in ipairs(context.scoring_hand) do
        if v.ability.name == "Wild Card" then
          wilds[#wilds+1] = v
          v:set_edition({ polychrome = true }, true)
          G.E_MANAGER:add_event(Event({
            func = function()
              v:juice_up()
              return true
            end
          }))
        end
      end
      if #wilds > 0 then
        return {
          message = 'Polychrome!',
          colour = G.C.DARK_EDITION,
        }
      end
    end
  end
}
SMODS.Joker {
  key = 'penrose',
  loc_txt = {
    name = 'Penrose',
    text = {
      "If played hand contains",
      "exactly {C:attention}three{} cards and",
      "one {C:attention}3{}, {C:attention}transform{} played cards",
      "into that {C:attention}3{}",
      "{C:inactive}(After scoring){}"
    }
  },
  rarity = 3,
  atlas = 'T.Jokers',
  pos = { x = 0, y = 1 },
  cost = 10,
  calculate = function(self, card, context)
    if context.after then
      if #G.play.cards ~= 3 then return nil, false end
      local threes = {}
      for _, card in pairs(G.play.cards) do
        if card:get_id() == 3 then
          threes[#threes + 1] = card
        end
      end
      if #threes == 1 then
        for _, card in pairs(G.play.cards) do
          if card ~= threes[1] then
            copy_card(threes[1], card)
          end
        end
      end
      return nil, true
    end
  end
}
SMODS.Joker {
  key = 'waterfall',
  loc_txt = {
    name = 'Waterfall',
    text = {
      "{C:mult}+#1#{} discard per round",
      "Gains {C:chips}+#2#{} chips when",
      "a {C:attention}discard {}is used",
      "{C:inactive}(Currently {}{C:chips}+#3#{} {C:inactive}chips){}"
    }
  },
  rarity = 3,
  atlas = 'T.Jokers',
  pos = { x = 1, y = 1 },
  cost = 8,
  config = { extra = { d_size = 1, chips = 0, chips_mod = 3, first = 0} },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.d_size, card.ability.extra.chips_mod, card.ability.extra.chips } }
  end,
  add_to_deck = function(self, card, from_debuff)
    -- Changes a G.GAME variable, which is usually a global value that's specific to the current run.
    -- These are initialized in game.lua under the Game:init_game_object() function, and you can look through them to get an idea of the things you can change.
    G.GAME.round_resets.discards = G.GAME.round_resets.discards + card.ability.extra.d_size
  end,
  -- Inverse of above function.
  remove_from_deck = function(self, card, from_debuff)
    -- Adds - instead of +, so they get subtracted when this card is removed.
    G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.d_size
  end,
  -- Because all the functionality is in remove_from_deck and add_to deck, calculate is unnecessary.
  calculate = function(self, card, context)
    if context.pre_discard and not context.blueprint then
      card:juice_up(0.3, 0.4)
      card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chips_mod
      card.ability.extra.first = 0
    end
    if context.discard and card.ability.extra.first == 0 then
      card.ability.extra.first = 1
      return {
        message = localize('k_upgrade_ex'),
        colour = G.C.CHIPS,
      }
    end
    if context.joker_main then
      return {
        message = localize{type='variable',key='a_chips',vars={card.ability.extra.chips}},
        chip_mod = card.ability.extra.chips,
        colour = G.C.CHIPS
      }
    end
  end

}

SMODS.Joker {
  key = 'dada',
  loc_txt =  {
    name = 'Dada Joker',
    text = {
      "{C:chips}+#1#{} chips for each {C:attention}Joker{}"
    }
  },
  rarity = 1,
  atlas = 'T.Jokers',
  pos = { x = 2, y = 1 },
  cost = 5,
  config = { extra = { chips_add = 25 } },
  loc_vars = function(self, info_queue, card)
    local total_cards = (G.jokers and #G.jokers.cards or 0)
    return { vars = { card.ability.extra.chips_add, total_cards*card.ability.extra.chips_add } }
  end,

  calculate = function(self, card, context)
    if context.joker_main then
        local total_cards = #G.jokers.cards
        return {
            message = localize{type='variable',key='a_chips',vars={total_cards*card.ability.extra.chips_add}},
            chip_mod = total_cards*card.ability.extra.chips_add,
            colour = G.C.CHIPS
        }
    end
  end

}

SMODS.Joker {
  key = 'impos',
  loc_txt = {
    name = 'Impossibility',
    text = {
      "{X:mult,C:white}X#1#{} Mult if played hand",
      "contains a {C:attention}2{} and an {C:attention}8{}"
    }
  },
  config = { extra = { Xmult = 3, twos = false, eights = false } },
  rarity = 3,
  atlas = 'T.Jokers',
  pos = { x = 3, y = 1 },
  cost = 8,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.Xmult } }
  end,

  calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play then
      for i = 1, #context.scoring_hand do
        if context.other_card:get_id() == 2 then
          card.ability.extra.twos = true
        elseif context.other_card:get_id() == 8 then
          card.ability.extra.eights = true
        end
      end
    end
    if context.joker_main and card.ability.extra.twos == true and card.ability.extra.eights == true then
      card.ability.extra.twos = false
      card.ability.extra.eights = false
      return {
        message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.Xmult } },
        Xmult_mod = card.ability.extra.Xmult
      }
    end
  end
}

SMODS.Joker {
  key = 'bismuth',
  loc_txt = {
    name = 'Bismuth',
    text = {
      "Played {C:attention}Wild {}cards",
      "are retriggered",
      "{C:attention}#1#{} times when scored"
    }
  },
  config = { extra = { repetitions = 2 } },
  loc_vars = function(self, info_queue, card)
    return {vars = { card.ability.extra.repetitions } } 
  end,
  atlas = 'T.Jokers',
  pos = { x = 4, y = 0 },
  rarity = 2,
  cost = 7,
  calculate = function(self, card, context)
    -- Checks that the current cardarea is G.play, or the cards that have been played, then checks to see if it's time to check for repetition.
    -- The "not context.repetition_only" is there to keep it separate from seals.
    if context.cardarea == G.play and context.repetition and not context.repetition_only then
      -- context.other_card is something that's used when either context.individual or context.repetition is true
      -- It is each card 1 by 1, but in other cases, you'd need to iterate over the scoring hand to check which cards are there.
      if context.other_card.ability.name == "Wild Card" then
        return {
          message = 'Again!',
          repetitions = card.ability.extra.repetitions,
          -- The card the repetitions are applying to is context.other_card
          card = context.other_card
        }
      end
    end
  end

}
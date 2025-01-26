SMODS.Atlas {
    key = "T.Jokers",
    path = "Jokers.png",
    px = 71,
    py = 95,
}
SMODS.Joker { --blue_java
    key = "blue_java",
    loc_txt =  	{
        name = 'Blue Java',
        text = {
            "{C:chips}+#1#{} Chips"
        },
    },

    yes_pool_flag = 'gros_michel_extinct',
    config = { extra = { chips = 200 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips } }
      end,
    -- Sets rarity. 1 common, 2 uncommon, 3 rare, 4 legendary.
    rarity = 2,
    perishable_compat = true,
    blueprint_compat = true,
    eternal_compat = true,
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

SMODS.Joker { --mint
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
  blueprint_compat = false,
  perishable_compat = true,
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

SMODS.Joker { --chroma
  key = 'chroma',
  loc_txt = {
    name = 'Chromatic Aberration',
    text = {
      "Played {C:attention}Wild Cards{} become",
      "{C:dark_edition}Polychrome{} before scoring"
    }
  },
  rarity = 3,
  atlas = 'T.Jokers',
  pos = { x = 2, y = 0 },
  soul_pos = { x = 3, y = 0 },
  cost = 9,
  blueprint_compat = false,
  perishable_compat = true,
  eternal_compat = true,
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

SMODS.Joker { --penrose
  key = 'penrose',
  loc_txt = {
    name = 'Penrose',
    text = {
      "If played hand contains",
      "exactly {C:attention}three{} cards and",
      "one {C:attention}3{}, {C:attention}transform{} ",
      "played cards into that {C:attention}3{}",
      "{C:inactive}(After scoring){}"
    }
  },
  rarity = 3,
  atlas = 'T.Jokers',
  pos = { x = 0, y = 1 },
  cost = 10,
  perishable_compat = true,
  blueprint_compat = false,
  eternal_compat = true,
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

SMODS.Joker { --waterfall
  key = 'waterfall',
  loc_txt = {
    name = 'Waterfall',
    text = {
      "{C:mult}+#1#{} discard per round",
      "Gains {C:chips}+#2#{} Chips when",
      "a {C:attention}3 {}or {C:attention}9{} is discarded",
      "{C:inactive}(Currently {}{C:chips}+#3#{} {C:inactive}chips){}"
    }
  },
  rarity = 3,
  atlas = 'T.Jokers',
  pos = { x = 1, y = 1 },
  cost = 8,
  perishable_compat = false,
  eternal_compat = true,
  blueprint_compat = true,
  config = { extra = { d_size = 1, chips = 0, chips_mod = 3 } },
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
    if context.discard and not context.blueprint and not context.other_card.debuff then 
      if context.other_card:get_id() == 3 or context.other_card:get_id() == 9 then
        card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chips_mod
        return {
          message = localize('k_upgrade_ex'),
          colour = G.C.CHIPS,
          message_card = card
        }
      end
    end
    if context.joker_main then
      return {
        message = localize{type='variable',key='a_chips',vars={card.ability.extra.chips}},
        chips = card.ability.extra.chips,
        colour = G.C.CHIPS
      }
    end
  end

}

SMODS.Joker { --dada
  key = 'dada',
  loc_txt =  {
    name = 'Dada Joker',
    text = {
      "{C:chips}+#1#{} Chips for each {C:attention}Joker {}card",
      "{C:inactive}(Currently {C:chips}+#2#{} {C:inactive}Chips){}"
    }
  },
  rarity = 1,
  atlas = 'T.Jokers',
  pos = { x = 2, y = 1 },
  cost = 5,
  perishable_compat = true,
  blueprint_compat = true,
  eternal_compat = true,
  config = { extra = { chips_add = 20 } },
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

SMODS.Joker { --impos
  key = 'impos',
  loc_txt = {
    name = 'Impossibility',
    text = {
      "{X:mult,C:white}X#1#{} Mult if scored hand",
      "contains a {C:attention}2{} and an {C:attention}8{}"
    }
  },
  config = { extra = { Xmult = 3, twos = false, eights = false } },
  rarity = 2,
  atlas = 'T.Jokers',
  pos = { x = 3, y = 1 },
  cost = 8,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.Xmult } }
  end,
  perishable_compat = true,
  blueprint_compat = true,
  eternal_compat = true,
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

SMODS.Joker { --bismuth
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
  perishable_compat = true,
  blueprint_compat = true,
  eternal_compat = true,
  atlas = 'T.Jokers',
  pos = { x = 4, y = 0 },
  rarity = 2,
  cost = 7,
  calculate = function(self, card, context)
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

SMODS.Joker { --jimbette
  key = 'jimbette',
  loc_txt = {
    name = 'Jimbette',
    text = {
      "Gains {C:mult}+#1# {}Mult for every",
      "{C:attention}7{} {C:hearts}Hearts{} scored {C:inactive}({C:attention}#3#{C:inactive} left)",
      "{C:inactive}(Currently{} {C:mult}+#2#{C:inactive} Mult)"
    }
  },
  cost = 6,
  perishable_compat = false,
  blueprint_compat = true,
  eternal_compat = true,
  rarity = 2,
  atlas = 'T.Jokers',
  pos = { x = 4, y = 1 },
  config = { extra = { mult = 0, mult_gain = 4, num = 0, jh = 7 } },
  loc_vars = function(self, info_queue, card)
    return {vars = { card.ability.extra.mult_gain, card.ability.extra.mult, card.ability.extra.jh } }
  end,
  calculate = function(self, card, context)
    if not context.blueprint then
      if context.individual and context.cardarea == G.play then
        if context.other_card:is_suit("Hearts") then
          card.ability.extra.num = card.ability.extra.num + 1
          card.ability.extra.jh = card.ability.extra.jh - 1
        end
        if card.ability.extra.num >= 7 then 
          card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
          card.ability.extra.num = 0
          card.ability.extra.jh = 7
          return {
            message = localize('k_upgrade_ex'),
            colour = G.C.MULT,
          }
        end
      end
    end
    if context.joker_main then
      return {
        mult = card.ability.extra.mult
      }
    end
  end
}

SMODS.Joker { --conduit
  key = 'conduit',
  loc_txt = {
    name = 'Conduit',
    text = {
      "Scored {C:attention}Mult{} cards",
      "give {C:chips}+#1#{} Chips",
      "Scored {C:attention}Bonus{} cards",
      "give {C:mult}+#2#{} Mult"
    }
  },
  cost = 4,
  rarity = 1,
  atlas = 'T.Jokers',
  pos = { x = 5, y = 0 },
  eternal_compat = true,
  perishable_compat = true,
  blueprint_compat = true,
  config = { extra = { chips = 30, mult = 4 } },
  loc_vars = function(self, info_queue, card)
    return {vars = { card.ability.extra.chips, card.ability.extra.mult } }
  end,
  calculate = function(self, card, context)
    -- Checks that the current cardarea is G.play, or the cards that have been played, then checks to see if it's time to check for repetition.
    -- The "not context.repetition_only" is there to keep it separate from seals.
    if context.individual and context.cardarea == G.play then
      -- context.other_card is something that's used when either context.individual or context.repetition is true
      -- It is each card 1 by 1, but in other cases, you'd need to iterate over the scoring hand to check which cards are there.
      if context.other_card.ability.name == "Bonus" then
        return {
          mult = card.ability.extra.mult,
          card = context.other_card
        }
      elseif context.other_card.ability.name == "Mult" then
        return {
          chips = card.ability.extra.chips,
          card = context.other_card
        }
      end
    end
  end
}

SMODS.Joker { --mahjong
  key = 'mahjong',
  loc_txt = {
    name = 'Mahjong Tile',
    text = {
      "Earn {C:money}$#1#{} if played hand contains a {C:attention}Pair{}"
    }
  },
  rarity = 2,
  cost = 6,
  perishable_compat = true,
  eternal_compat = true,
  blueprint_compat = true,
  atlas = 'T.Jokers',
  pos = { x = 5, y = 1 },
  config = { extra = { dollars = 2 } },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.dollars } }
  end,
  calculate = function(self, card, context)
    if context.before and next(context.poker_hands['Pair']) then
      ease_dollars(card.ability.extra.dollars)
      return {
        message = localize('$')..card.ability.extra.dollars,
        colour = G.C.MONEY
      }
    end
  end
}

SMODS.Joker { --pineapple
  key = 'pineapple',
  loc_txt = {
    name = 'Pineapple',
    text = {
      "{C:chips}+#1#{} Chips",
      "{C:chips}-#2#{} Chips if {C:attention}first{} played hand",
      "doesn't beat the {C:attention}blind{}"
    }
  },
  rarity = 1,
  cost = 6,
  eternal_compat = false,
  perishable_compat = true,
  blueprint_compat = true,
  atlas = "T.Jokers",
  pos = { x = 1, y = 2 },
  config = { extra =  { chips = 160, chips_mod = 40 } },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.chips, card.ability.extra.chips_mod } }
  end,
  calculate = function (self, card, context)
    if context.joker_main then
        return {
            chips = card.ability.extra.chips,
        }
    end
    if context.end_of_round and not context.repetition and not context.individual and not context.blueprint and G.GAME.current_round.hands_played > 1 then
        card.ability.extra.chips = card.ability.extra.chips - card.ability.extra.chips_mod
        if card.ability.extra.chips <= 0 then
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
          message = localize{type='variable',key='a_chips_minus',vars={card.ability.extra.chips_mod}},
          colour = G.C.CHIPS,
        }
      end
    end
  end
}

SMODS.Joker { --pie
  key = 'pie',
  loc_txt = {
    name = 'Apple Pie',
    text = {
      "{C:mult}+#1#{} Mult",
      "{C:mult}-#2#{} Mult if {C:attention}first{} played hand",
      "doesn't beat the {C:attention}blind{}"
    }
  },
  rarity = 1,
  cost = 6,
  atlas = "T.Jokers",
  pos = { x = 0, y = 2 },
  eternal_compat = false,
  perishable_compat = true,
  blueprint_compat = true,
  config = { extra =  { mult = 24, mult_mod = 6 } },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.mult, card.ability.extra.mult_mod } }
  end,
  calculate = function (self, card, context)
    if context.joker_main then
        return {
            mult = card.ability.extra.mult,
        }
    end
    if context.end_of_round and not context.repetition and not context.individual and not context.blueprint and G.GAME.current_round.hands_played > 1 then
        card.ability.extra.mult = card.ability.extra.mult - card.ability.extra.mult_mod
        if card.ability.extra.mult <= 0 then
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
          message = localize{type='variable',key='a_mult_minus',vars={card.ability.extra.mult_mod}},
          colour = G.C.MULT,
        }
      end
    end
  end
}

SMODS.Joker { --blocks
  key = 'blocks',
  loc_txt = {
    name = "Letter Blocks",
    text = {
      "Gains {C:mult}+#1#{} Mult for each",
      "{C:attention}lettered{} card {C:inactive}(A, K, Q, J) {}scored",
      "in {C:attention}first hand{} of round",
      "{C:inactive}(Currently {C:mult}+#2# {C:inactive}Mult){}"

    }
  },
  rarity = 2,
  cost = 6,
  eternal_compat = true,
  perishable_compat = false,
  blueprint_compat = true,
  atlas = "T.Jokers",
  pos = { x = 2, y = 2 },
  config = { extra = { mult = 0, mult_gain = 2 } },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.mult_gain, card.ability.extra.mult } }
  end,
  calculate = function (self, card, context)
    if context.individual and context.cardarea == G.play and G.GAME.current_round.hands_played == 0 and not context.blueprint then
      if context.other_card:is_face() or context.other_card:get_id() == 14 then
        card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
        return {
            extra = {message = localize('k_upgrade_ex'), colour = G.C.MULT},
            colour = G.C.MULT,
            card = context.other_card
        }
      end
    end
    if context.joker_main then
      return {
        mult = card.ability.extra.mult
      }
    end
  end


}

SMODS.Joker {
  key = 'reserve',
  loc_txt = {
    name = "Reserve Leaflet",
    text = {
      "{X:mult,C:white}X#1#{} Mult for each {C:rare}Rare{C:attention} Joker"
    }
  },
  cost = 7,
  rarity = 2,
  atlas = 'T.Jokers',
  pos = { x = 3, y = 2 },
  config = { extra = { xmult = 2 } },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.xmult } }
  end,
  eternal_compat = true,
  perishable_compat = true,
  blueprint_compat = true,
  calculate = function(self, card, context)
    if context.other_joker then 
      if context.other_joker.config.center.rarity == 3 or context.other_joker.config.center.rarity == "Rare" then
        G.E_MANAGER:add_event(Event({
            func = function()
                context.other_joker:juice_up(0.5, 0.5)
                return true
            end
        })) 
        return {
            message = localize{type='variable',key='a_xmult',vars={card.ability.extra.xmult}},
            Xmult_mod = card.ability.extra.xmult
        }
      end
    end
  end
}

mod_prefix = "se-"
data.raw.item[mod_prefix .. "cargo-rocket-section-packed"].stack_size = 10
data.raw.item["rocket-fuel"].stack_size = 50
local capsule_stack_size = 25
data:extend({
      {
          type = "item",
          name = "delivery-cannon-capsule-stacked",
          icon = "__Space-Exploration-Rocket-Part-Delivery__/delivery-cannon-capsule-stacked.png",
          icon_size = 64,
          subgroup = "rocket-logistics",
          order = "j-d",
          stack_size = 1,
      },
      {
        type = "recipe",
        name = "delivery-cannon-capsule-packing",
        result = "delivery-cannon-capsule-stacked",
        energy_required = 10,
        ingredients = {
          { mod_prefix .. "delivery-cannon-capsule", capsule_stack_size }
        },
        order='z-z-z-z-z',
        requester_paste_multiplier = 2,
        enabled = false,
        always_show_made_in = false,
        allow_as_intermediate = false,
    },{
        type = "recipe",
        name = "delivery-cannon-capsule-unpacking",
        results = {
          { mod_prefix .. "delivery-cannon-capsule", capsule_stack_size }
        },
        energy_required = 10,
        ingredients = {
          { "delivery-cannon-capsule-stacked", 1 }
        },
        order='z-z-z-z',
        requester_paste_multiplier = 2,
        enabled = false,
        always_show_made_in = false,
        allow_as_intermediate = false,
    }
    })
table.insert(data.raw.technology[mod_prefix .. "delivery-cannon"].effects, {type = "unlock-recipe", recipe = "delivery-cannon-capsule-packing"} )
table.insert(data.raw.technology[mod_prefix .. "delivery-cannon"].effects, {type = "unlock-recipe", recipe = "delivery-cannon-capsule-unpacking"} )
-- defaults to stack size for items
c_se_delivery_cannon_recipes = {}
c_se_delivery_cannon_recipes[mod_prefix .. "cargo-rocket-section-packed"] = {name=mod_prefix .. "cargo-rocket-section-packed"}
c_se_delivery_cannon_recipes["delivery-cannon-capsule-stacked"] = {name="delivery-cannon-capsule-stacked"}
c_se_delivery_cannon_recipes[mod_prefix .. "space-capsule"] = {name=mod_prefix .. "space-capsule"}


for _, resource in pairs(c_se_delivery_cannon_recipes) do
  local type = resource.type or "item"
  if data.raw[type][resource.name] then
    local base = data.raw[type][resource.name]
    local amount = resource.amount
    if not amount then
      if type == "fluid" then
        amount = 1000
      else
        amount = base.stack_size or 1
      end
    end
    local order = ""
    local o_subgroup = data.raw["item-subgroup"][base.subgroup]
    local o_group = data.raw["item-group"][o_subgroup.group]
    order = o_group.order .. "-|-"..o_subgroup.order.."-|-"..base.order
    data:extend({
      {
          type = "item",
          name = mod_prefix .. "delivery-cannon-package-"..resource.name,
          icon = "__space-exploration-graphics__/graphics/icons/delivery-cannon-capsule.png",
          icon_size = 64,
          order = order,
          flags = {"hidden"},
          subgroup = base.subgroup or "delivery-cannon-capsules",
          stack_size = 1,
          localised_name = {"item-name.se-delivery-cannon-capsule-packed", base.localised_name or {type.."-name."..resource.name}}
      },
      {
          type = "recipe",
          name = mod_prefix .. "delivery-cannon-pack-" .. resource.name,
          icon = base.icon,
          icon_size = base.icon_size,
          icon_mipmaps = base.icon_mipmaps,
          icons = base.icons,
          result = mod_prefix .. "delivery-cannon-package-"..resource.name,
          enabled = true,
          energy_required = 5,
          ingredients = {
            { mod_prefix .. "delivery-cannon-capsule", 1 },
            { type = type, name = resource.name, amount = amount},
          },
          requester_paste_multiplier = 1,
          always_show_made_in = false,
          category = "delivery-cannon",
          hide_from_player_crafting = true,
          localised_name = {"item-name.se-delivery-cannon-capsule-packed", base.localised_name or {type.."-name."..resource.name}}
      },
    })
    local unlock_tech
    local recipe_name = mod_prefix .. "delivery-cannon-package-"..resource.name
      for _, technology in pairs(data.raw.technology) do
        if technology.effects then
          for _, effect in pairs(technology.effects) do
            if effect.recipe == recipe_name then
              table.insert(technology.effects, { type = "unlock-recipe", recipe = mod_prefix .. "delivery-cannon-pack-" .. resource.name})
              unlock_tech = technology
              break
            end
          end
          if unlock_tech then break end
        end
      end
  end
end
local flib = require('__flib__.data-util')

--- create loader item
-- @tparam String name
-- @tparam String subgroup
-- @tparam String order
-- @tparam Types.Color[] tint
function make_loader_item(name, subgroup, order, tint)
  return{
    type = "item",
    name = name,
    icons = {
      -- Base
      {
        icon = "__LoaderRedux__/graphics/icon/icon-loader-base.png",
        icon_size = 64,
        icon_mipmaps = 4,
      },
      -- Mask
      {
        icon = "__LoaderRedux__/graphics/icon/icon-loader-mask.png",
        icon_size = 64,
        icon_mipmaps = 4,
        tint = tint,
      },
    },
    subgroup = subgroup,
    order = order,
    place_result = name,
    stack_size = 50
  }
end

--- create loader entity
-- @tparam String name
-- @tparam Prototype.TransportBelt[] belt
-- @tparam Types.Color[] tint
-- @tparam String|nil next_upgrade
function make_loader_entity(name, belt, tint, next_upgrade)
  local loader = data.raw["loader"][name] or flib.copy_prototype(data.raw["loader"]["loader"], name)
  loader.flags = {"placeable-neutral", "placeable-player", "player-creation", "fast-replaceable-no-build-while-moving"}
  loader.icons = {
    -- Base
    {
      icon = "__LoaderRedux__/graphics/icon/icon-loader-base.png",
      icon_size = 64,
      icon_mipmaps = 4,
    },
    -- Mask
    {
      icon = "__LoaderRedux__/graphics/icon/icon-loader-mask.png",
      icon_size = 64,
      icon_mipmaps = 4,
      tint = tint,
    },
  }

  loader.structure.front_patch = {
    sheet = {
      filename= "__LoaderRedux__/graphics/entity/loader-front-patch.png",
      priority = "extra-high",
      width = 94,
      height = 79,
      shift = util.by_pixel(10, 2),
      hr_version = {
        filename= "__LoaderRedux__/graphics/entity/hr-loader-front-patch.png",
        priority = "extra-high",
        width = 186,
        height = 155,
        shift = util.by_pixel(9.5, 1.5),
        scale = 0.5,
      }
    }

  }
  loader.structure.direction_in = {
    sheets = {
      -- Base
      {
        filename= "__LoaderRedux__/graphics/entity/loader-base.png",
        priority = "extra-high",
        width = 94,
        height = 79,
        shift = util.by_pixel(10, 2),
        hr_version = {
          filename= "__LoaderRedux__/graphics/entity/hr-loader-base.png",
          priority = "extra-high",
          width = 186,
          height = 155,
          shift = util.by_pixel(9.5, 1.5),
          scale = 0.5,
        }
      },
      -- Mask
      {
        filename= "__LoaderRedux__/graphics/entity/loader-mask.png",
        priority = "extra-high",
        width = 94,
        height = 79,
        shift = util.by_pixel(10, 2),
        tint = tint,
        hr_version = {
          filename= "__LoaderRedux__/graphics/entity/hr-loader-mask.png",
          priority = "extra-high",
          width = 186,
          height = 155,
          shift = util.by_pixel(9.5, 1.5),
          tint = tint,
          scale = 0.5,
        }
      },
      -- Shadow
      {
        filename= "__LoaderRedux__/graphics/entity/loader-shadow.png",
        priority = "extra-high",
        width = 94,
        height = 79,
        shift = util.by_pixel(10, 2),
        draw_as_shadow = true,
        hr_version = {
          filename= "__LoaderRedux__/graphics/entity/hr-loader-shadow.png",
          priority = "extra-high",
          width = 186,
          height = 155,
          shift = util.by_pixel(9.5, 1.5),
          draw_as_shadow = true,
          scale = 0.5,
        }
      },
      -- Lights
      {
        filename= "__LoaderRedux__/graphics/entity/loader-lights.png",
        priority = "extra-high",
        width = 94,
        height = 79,
        shift = util.by_pixel(10, 2),
        draw_as_light = true,
        hr_version = {
          filename= "__LoaderRedux__/graphics/entity/hr-loader-lights.png",
          priority = "extra-high",
          width = 186,
          height = 155,
          shift = util.by_pixel(9.5, 1.5),
          draw_as_light = true,
          scale = 0.5,
        }
      },
    }
  }
  loader.structure.direction_out = {
    sheets = {
      -- Base
      {
        filename= "__LoaderRedux__/graphics/entity/loader-base.png",
        priority = "extra-high",
        y = 79,
        width = 94,
        height = 79,
        shift = util.by_pixel(10, 2),
        hr_version = {
          filename= "__LoaderRedux__/graphics/entity/hr-loader-base.png",
          priority = "extra-high",
          y = 155,
          width = 186,
          height = 155,
          shift = util.by_pixel(9.5, 1.5),
          scale = 0.5,
        }
      },
      -- Mask
      {
        filename= "__LoaderRedux__/graphics/entity/loader-mask.png",
        priority = "extra-high",
        width = 94,
        height = 79,
        shift = util.by_pixel(10, 2),
        tint = tint,
        hr_version = {
          filename= "__LoaderRedux__/graphics/entity/hr-loader-mask.png",
          priority = "extra-high",
          width = 186,
          height = 155,
          shift = util.by_pixel(9.5, 1.5),
          tint = tint,
          scale = 0.5,
        }
      },
      -- Shadow
      {
        filename= "__LoaderRedux__/graphics/entity/loader-shadow.png",
        priority = "extra-high",
        width = 94,
        height = 79,
        shift = util.by_pixel(10, 2),
        draw_as_shadow = true,
        hr_version = {
          filename= "__LoaderRedux__/graphics/entity/hr-loader-shadow.png",
          priority = "extra-high",
          width = 186,
          height = 155,
          shift = util.by_pixel(9.5, 1.5),
          draw_as_shadow = true,
          scale = 0.5,
        }
      },
      -- Lights
      {
        filename= "__LoaderRedux__/graphics/entity/loader-lights.png",
        priority = "extra-high",
        y = 79,
        width = 94,
        height = 79,
        shift = util.by_pixel(10, 2),
        draw_as_light = true,
        hr_version = {
          filename= "__LoaderRedux__/graphics/entity/hr-loader-lights.png",
          priority = "extra-high",
          y = 155,
          width = 186,
          height = 155,
          shift = util.by_pixel(9.5, 1.5),
          draw_as_light = true,
          scale = 0.5,
        }
      },
    }
  }

  loader.speed = belt.speed
  loader.next_upgrade = next_upgrade

  -- 0.17 animations
  loader.belt_animation_set = belt.belt_animation_set
  loader.structure_render_layer = "object"

  return loader
end

data:extend({
  {
    type = "recipe",
    name = "space-loader",
    category = "crafting-with-fluid",
    enabled = false,
    hidden = false,
    energy_required = 5,
    ingredients = {
      {"iron-gear-wheel", 20},
      {"processing-unit", 5},
      {"express-loader", 1},
      {type="fluid", name="lubricant", amount=80},
    },
    result = "space-loader"
  },
})
-- create loaders
local belt_prototypes = data.raw["transport-belt"]

data:extend({
  make_loader_item("space-loader", "belt", "d-d", util.color("d9d9d9d9")),
  make_loader_entity("space-loader", belt_prototypes[mod_prefix .. "space-transport-belt"], util.color("d9d9d9d9"), nil),
})

local loader_techs = {
  [mod_prefix .. "space-platform-scaffold"] = "space-loader",
}

for tech, recipe in pairs(loader_techs) do
  if data.raw.technology[tech] then
    table.insert(data.raw.technology[tech].effects, {type = "unlock-recipe", recipe = recipe} )
  end
end
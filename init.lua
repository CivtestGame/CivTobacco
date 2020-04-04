
-- tobacco plant
farming.register_plant("civtobacco:leaves", {
	description = ("Tobacco seeds"),
	harvest_description = ("tobacco leaves"),
	inventory_image = "civtobacco_seed.png",
	steps = 7,
	minlight = 13,
	maxlight = default.LIGHT_MAX,
	fertility = {"grassland", "desert"},
        custom_growth = {optimum_heat = 75, heat_scaling = "exponential", heat_a = 10, heat_b = 1.2, heat_base_speed = 2500, variance = 500},
	groups = {tobacco = 1,flammable = 4}, --A new item group that will probably not be used for anything
	})
-- This item emits smoke when used
minetest.register_craftitem("civtobacco:cigarette", {
    description = "Cigarette",
    inventory_image = "civtobacco_cigarette.png",
    groups = {tobacco = 1},
    on_use = function(itemstack, player, pointed_thing)
    --Flavour text
       minetest.chat_send_player(player:get_player_name(),"You smoke the cigarette")
    tbsmoke(14,player:get_pos())
    --Plays one of two sounds at the player who smoked position
       tbsound("smoke", player:get_pos())
-- Replaces the cigarette with a recyclable waste product
        return "civtobacco:cigbutt"
    end,
})

-- These can be chewed, or made into snuff or cigarettes
minetest.register_craftitem("civtobacco:leaves_cured", {
    description = "Dried tobacco leaves",
    inventory_image = "civtobacco_cured.png",
    groups = {tobacco = 1},
    on_use = function(itemstack, player, pointed_thing)
   --Send player message with flavour text
    minetest.chat_send_player(player:get_player_name(),"You chew the tobacco")
--Plays one sound at the player who chewed position
tbsound("chew", player:get_pos())
itemstack:take_item()
    return itemstack
end
})

minetest.register_craftitem("civtobacco:snuff", {
    description = "Snuff",
    inventory_image = "civtobacco_snuff.png",
    groups = {tobacco = 1},
    on_use = function(itemstack, player, pointed_thing)
    --Send player message with flavour text
    minetest.chat_send_player(player:get_player_name(),"You take the snuff up your nose")
--Plays one sound at the player who snorted position
   tbsound("snuff", player:get_pos())
   itemstack:take_item()
    return itemstack
end
})
minetest.register_craftitem("civtobacco:cigbutt", {
    description = "Cigarette butt",
    inventory_image = "civtobacco_cigbutt.png",
    groups = {tobacco = 1},
})

--Functions
--Sound function
function tbsound(sound,smokepos)
minetest.sound_play(sound, {
    pos = {x=smokepos.x, y=smokepos.y, z=smokepos.z},
	max_hear_distance = 12,
	gain = 5.0,
})
end

--Smoke particle function
function tbsmoke(particles,smokepos)
       --Make some particles, the texture is only randomized per cigarette
       minetest.add_particlespawner({
             amount = particles,
             time = 0.1,
             minpos = {x=smokepos.x, y=smokepos.y+1.5,z=smokepos.z},
             maxpos = {x=smokepos.x, y=smokepos.y+1.5,z=smokepos.z},
             minvel = {x=-0.1, y=0, z=-0.1},
             maxvel = {x=0.1, y=0.1, z=0.1},
             minacc = {x=0, y=0, z=0},
             maxacc = {x=0, y=0, z=0},
             minexptime = 10,
             maxexptime = 15,
             minsize = 1,
             maxsize = 2,
             collisiondetection = true,
             vertical = false,
             texture = "civtobacco_smoke." .. math.random(1,3) .. ".png",
       })
end
--Crafting recipes
--"Cook" leaves into cured versions for crafting
minetest.register_craft({
    type = "cooking",
    output = "civtobacco:leaves_cured",
    recipe = "civtobacco:leaves",
    cooktime = 30,
})
-- Recipe for the cigarette
minetest.register_craft({
    type = "shapeless",
    output = "civtobacco:cigarette",
    recipe = {
        "civtobacco:leaves_cured",
        "default:paper",
    },
})

-- Recipe for the snuff
minetest.register_craft({
    type = "shapeless",
    output = "civtobacco:snuff",
    recipe = {
        "civtobacco:leaves_cured",
    },
})

-- Recipe using three cigarette butts to make a cigarette
minetest.register_craft({
    type = "shapeless",
    output = "civtobacco:cigarette",
    recipe = {
        "civtobacco:cigbutt",
        "civtobacco:cigbutt",
        "civtobacco:cigbutt",
    },
})

-- Recipe to make seeds
minetest.register_craft({
    type = "shapeless",
    output = "civtobacco:seed_leaves 2",
    recipe = {
        "civtobacco:leaves",
    },
})
--Enable tobacco to exist by making it drop from grass
for i = 1, 3 do
	minetest.override_item("default:marram_grass_"..i, {drop = {
		max_items = 1,
		items = {
			{items = {"civtobacco:seed_leaves"},rarity = 10},
			{items = {"default:marram_grass_1"}},
		}
	}})
end


-- tobbaco
farming.register_plant("tobbaco:leaves", {
	description = ("Tobbaco seeds"),
	harvest_description = ("tobbaco leaves"),
	inventory_image = "tobbaco_seed.png",
	steps = 7,
	minlight = 13,
	maxlight = default.LIGHT_MAX,
	fertility = {"grassland", "desert"},
        custom_growth = {optimum_heat = 75, heat_scaling = "exponential", heat_a = 10, heat_b = 1.2, heat_base_speed = 2500, variance = 500},                          
	groups = {tobbaco = 1,flammable = 4}, --A new item group that will probably not be used for anything
	})
-- This item emits smoke when used
minetest.register_craftitem("tobbaco:cigarette", {
    description = "Cigarette",
    inventory_image = "tobbaco_cigarette.png",
    groups = {tobbaco = 1},
    on_use = function(itemstack, player, pointed_thing)
    minetest.chat_send_player(player:get_player_name(),"You smoke the cigarette") 
    smokepos = player:get_pos() 
      minetest.add_particlespawner({
	amount = 16,
	time = 1,
	minpos = {x=smokepos.x, y=smokepos.y+1.5,z=smokepos.z},
	maxpos = {x=smokepos.x, y=smokepos.y+1.5,z=smokepos.z},
	minvel = {x=-0.1, y=0, z=-0.1},
	maxvel = {x=0.1, y=0.1, z=0.1},
	minacc = {x=0, y=0, z=0},
	maxacc = {x=0, y=0, z=0},
	minexptime = 32,
	maxexptime = 64,
	minsize = 0.5,
	maxsize = 1.5,
	collisiondetection = true,
	vertical = false,
	texture = "tobbaco_smoke." .. math.random(1,3) .. ".png",
})
--Plays one of two sounds at the player who smoked position
    minetest.sound_play("smoke", {
    pos = {x=smokepos.x, y=smokepos.y, z=smokepos.z},
	max_hear_distance = 10,
	gain = 6.0,
})
-- Replaces the cigarette with a recyclable waste product
        return "tobbaco:cigbutt"
    end,
})

-- These can be chewed, or made into snuff or cigarettes
minetest.register_craftitem("tobbaco:leaves_cured", {
    description = "Dried tobbaco leaves",
    inventory_image = "tobbaco_cured.png",
    groups = {tobbaco = 1},
    on_use = function(itemstack, player, pointed_thing)
    smokepos = player:get_pos()
    minetest.chat_send_player(player:get_player_name(),"You chew the tobbaco") 
   
--Plays one of two sounds at the player who smoked position
    minetest.sound_play("chew", {
    pos = {x=smokepos.x, y=smokepos.y, z=smokepos.z},
	max_hear_distance = 8,
	gain = 5.0,
})
itemstack:take_item()
    return itemstack
end
})

minetest.register_craftitem("tobbaco:snuff", {
    description = "Snuff",
    inventory_image = "tobbaco_snuff.png",
    groups = {tobbaco = 1},
    on_use = function(itemstack, player, pointed_thing)
    smokepos = player:get_pos()
    minetest.chat_send_player(player:get_player_name(),"You take the snuff up your nose") 
   
--Plays one of two sounds at the player who smoked position
    minetest.sound_play("snuff", {
    pos = {x=smokepos.x, y=smokepos.y, z=smokepos.z},
	max_hear_distance = 10,
	gain = 6.0,
})
itemstack:take_item()
    return itemstack
end
})
minetest.register_craftitem("tobbaco:cigbutt", {
    description = "Cigarette butt",
    inventory_image = "tobbaco_cigbutt.png",
    groups = {tobbaco = 1},
})

--"Cook" leaves into cured versions for crafting
minetest.register_craft({
    type = "cooking",
    output = "tobbaco:leaves_cured",
    recipe = "tobbaco:leaves",
    cooktime = 30,
})
-- Recipe for the cigarette
minetest.register_craft({
    type = "shapeless", 
    output = "tobbaco:cigarette",
    recipe = {
        "tobbaco:leaves_cured",
        "default:paper",
    },
})

-- Recipe for the snuff
minetest.register_craft({
    type = "shapeless", 
    output = "tobbaco:snuff",
    recipe = {
        "tobbaco:leaves_cured",
    },
})

-- Recipe using three cigarette butts to make a cigarette
minetest.register_craft({
    type = "shapeless", 
    output = "tobbaco:cigarette",
    recipe = {
        "tobbaco:cigbutt",
        "tobbaco:cigbutt",
        "tobbaco:cigbutt",   
    },
})

-- Recipe to make seeds
minetest.register_craft({
    type = "shapeless",
    output = "tobbaco:seed_leaves 3",
    recipe = {
        "tobbaco:leaves",
    },
})

for i = 1, 3 do
	minetest.override_item("default:marram_grass_"..i, {drop = {
		max_items = 1,
		items = {
			{items = {"tobbaco:seed_leaves"},rarity = 10},
			{items = {"default:marram_grass_1"}},
		}
	}})
end


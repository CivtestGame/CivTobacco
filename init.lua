
-- tobbaco
farming.register_plant("tobacco:leaves", {
	description = ("tobacco seeds"),
	harvest_description = ("tobacco leaves"),
	inventory_image = "tobacco_seed.png",
	steps = 7,
	minlight = 13,
	maxlight = default.LIGHT_MAX,
	fertility = {"grassland", "desert"},
	groups = {drug = 1,flammable = 4}, --A new item group that will probably not be used for anything
	custom_growth = {optimum_heat = 75, heat_scaling = "exponential", heat_a = 10, heat_b = 1.2, heat_base_speed = 2500, variance = 500},
	})
-- This item emits smoke when used
minetest.register_craftitem("tobacco:cigarette", {
    description = "cigarette",
    inventory_image = "tobacco_cigarette.png",
    on_use = function(itemstack, player, pointed_thing)

    minetest.chat_send_player(player:get_player_name(),"You smoke the cigarette")
        smokepos = player:get_pos()
    minetest.add_particlespawner({
	amount = 13,
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
	texture = "tobacco_smoke." .. math.random(1,3) .. ".png",
})
--Plays one of three sounds to player who rolled
    minetest.sound_play("smoke", {
    to_player = player,
	gain = 6.0,
})
        return "default:paper"
    end,
})

minetest.register_craftitem("tobacco:leaves_cured", {
    description = "dried tobacco leaves",
    inventory_image = "tobacco_cured.png",
})



--"Cook" leaves into cured versions for crafting
minetest.register_craft({
    type = "cooking",
    output = "tobacco:leaves_cured",
    recipe = "tobacco:leaves",
    cooktime = 10,
})
-- Recipe for the cigarette
minetest.register_craft({
    type = "shapeless",
    output = "tobacco:cigarette",
    recipe = {
        "tobacco:leaves_cured",
        "default:paper",
    },
})

-- Recipe to make seeds
minetest.register_craft({
    type = "shapeless",
    output = "tobacco:seed_leaves 3",
    recipe = {
        "tobacco:leaves",
    },
})

for i = 1, 3 do
	minetest.override_item("default:marram_grass_"..i, {drop = {
		max_items = 1,
		items = {
			{items = {"tobacco:seed_leaves"},rarity = 10},
			{items = {"default:marram_grass_1"}},
		}
	}})
end

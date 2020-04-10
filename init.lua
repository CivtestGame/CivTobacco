-- Don't smoke. Nicotine is addictive and dangerous and tar from cigarettes even more so

timer = 0
--This checks players if they are addicted and if they have their fix
minetest.register_globalstep(
    function(dtime)
        timer = timer + dtime
        if timer > 30 then
            timer = 0
            for _, player in ipairs(minetest.get_connected_players()) do
                local pmeta = player:get_meta()
                if (pmeta:get_string("civtobacco:nicotine") == "depend") then
                    --minetest.chat_send_all("nicotine you be addicted")
                    tb_checkfix(player)
                    if (pmeta:get_string("civtobacco:nicotine_fix") == "need") then
                        minetest.chat_send_player(player:get_player_name(), tb_msg())
                        playerphysics.remove_physics_factor(player, "speed", "civtobacco")
                        hunger_spike(player)
                        if (math.random(1, 20) == 5) then
                            pmeta:set_string("civtobacco:nicotine", "not")
                        end
                    else
                        --Player is not addicted
                    end
                else
                    --minetest.chat_send_all("Debug nicotine not")
                end
            end
        end
    end
)

-- tobacco plant
farming.register_plant(
    "civtobacco:plant",
    {
        description = ("Tobacco Seeds"),
        harvest_description = ("tobacco leaves"),
        inventory_image = "civtobacco_seed.png",
        steps = 7,
        minlight = 13,
        maxlight = default.LIGHT_MAX,
        fertility = {"grassland", "desert"},
        custom_growth = {
            optimum_heat = 65,
            heat_scaling = "exponential",
            heat_a = 10,
            heat_b = 1.0,
            heat_base_speed = 2500,
            variance = 500,
            optimum_humidity = 40,
            humidity_scaling = "exponential",
            humidity_a = 1.5,
            humidity_b = 1,
            humidity_base_speed = 7500,
            variance = 2500
        },
        groups = {tobacco = 1, flammable = 4} --A new item group that will probably not be used for anything
    }
)

minetest.register_craftitem(
    "civtobacco:snuff",
    {
        description = "Snuff",
        inventory_image = "civtobacco_snuff.png",
        groups = {tobacco = 1, nicotine_raw = 1, flammable = 3},
        on_use = function(itemstack, player, pointed_thing)
            --Send player message with flavour text
            minetest.chat_send_player(player:get_player_name(), "You take the snuff up your nose")
            --Plays one sound at the player who snorted position
            tbsmoke(0, player, "snuff")
            tb_nicotine(player, 18, 1.50)
            itemstack:take_item()
            return itemstack
        end
    }
)

-- This item emits smoke when used
minetest.register_craftitem(
    "civtobacco:cigarette",
    {
        description = "Cigarette",
        inventory_image = "civtobacco_cigarette.png",
        groups = {tobacco = 1, flammable = 3},
        on_use = function(itemstack, player, pointed_thing)
            --Flavour text
            minetest.chat_send_player(player:get_player_name(), "You smoke the cigarette")
            tbsmoke(18, player, "smoke")
            tb_nicotine(player, 22, 1.75)
            -- Replaces the cigarette with a recyclable waste product
            -- Takes cigarette
            itemstack:take_item()
            givebutt(player)
            return itemstack
        end
    }
)

-- This item emits smoke when used
minetest.register_craftitem(
    "civtobacco:beedi",
    {
        description = "Beedi",
        inventory_image = "civtobacco_beedi.png",
        groups = {tobacco = 1, flammable = 3},
        on_use = function(itemstack, player, pointed_thing)
            --Flavour text
            minetest.chat_send_player(player:get_player_name(), "You smoke the beedi.")
            tbsmoke(16, player, "smoke")
            tb_nicotine(player, 28, 1.6)
            -- Replaces the beedi with a recyclable waste product
            -- Takes beddi
            itemstack:take_item()
            givebutt(player)
            return itemstack
        end
    }
)

-- This item emits smoke when used
minetest.register_craftitem(
    "civtobacco:cigar",
    {
        description = "Cigar",
        inventory_image = "civtobacco_cigar.png",
        groups = {tobacco = 1, flammable = 3},
        on_use = function(itemstack, player, pointed_thing)
            --Flavour text
            minetest.chat_send_player(player:get_player_name(), "You smoke the cigar. It's a little loose")
            tbsmoke(24, player, "smoke")
            tb_nicotine(player, 20, 1.6)
            -- Takes cigar and gives butt
            itemstack:take_item()
            givebutt(player)
            return itemstack
        end
    }
)

-- These can be chewed, or made into snuff or cigarettes etc
minetest.register_craftitem(
    "civtobacco:plant_cured",
    {
        description = "Dried Tobacco Leaves",
        inventory_image = "civtobacco_cured.png",
        groups = {tobacco = 1, nicotine_raw = 1, flammable = 3},
        on_use = function(itemstack, player, pointed_thing)
            --Send player message with flavour text
            minetest.chat_send_player(player:get_player_name(), "You chew the tobacco")
            --Plays one sound at the player who chewed position
            tbsmoke(0, player, "chew")
            tb_nicotine(player, 14, 1.3)
            itemstack:take_item()
            return itemstack
        end
    }
)
--Tobacco parts
minetest.register_craftitem(
    "civtobacco:cigbutt",
    {
        description = "Cigarette Butt",
        inventory_image = "civtobacco_cigbutt.png",
        groups = {tobacco = 1, flammable = 3}
    }
)

minetest.register_craftitem(
    "civtobacco:filter",
    {
        description = "Tobacco Smoke Filter",
        inventory_image = "civtobacco_filter.png",
        groups = {tobacco = 1, flammable = 3}
    }
)

minetest.register_craftitem(
    "civtobacco:paper",
    {
        description = "Smoking Paper",
        inventory_image = "civtobacco_paper.png",
        groups = {tobacco = 1, flammable = 3}
    }
)

--Functions

--Smoke particle and sound function
function tbsmoke(particles, smoker, sound)
    --Make some particles, the texture is only randomized per cigarette
    minetest.add_particlespawner(
        {
            amount = particles,
            time = 1,
            minpos = {x = smoker:get_pos().x, y = smoker:get_pos().y + 1.5, z = smoker:get_pos().z},
            maxpos = {x = smoker:get_pos().x, y = smoker:get_pos().y + 1.5, z = smoker:get_pos().z},
            minvel = {x = -0.1, y = 0, z = -0.1},
            maxvel = {x = 0.1, y = 0.1, z = 0.1},
            minacc = {x = 0, y = 0, z = 0},
            maxacc = {x = 0, y = 0, z = 0},
            minexptime = 10,
            maxexptime = 15,
            minsize = 1,
            maxsize = 2,
            collisiondetection = true,
            vertical = false,
            texture = "civtobacco_smoke." .. math.random(1, 3) .. ".png"
        }
    )
    minetest.sound_play(
        sound,
        {
            pos = smoker:get_pos(),
            max_hear_distance = 12,
            gain = 5.0
        }
    )
end

function tb_msg() --Returns a message
    local rnd = math.random(1, 4)
    if rnd == 1 then
        return "Your hands tremor"
    end
    if rnd == 2 then
        return "You feel suddenly hungry."
    end
    if rnd == 3 then
        return "Your crave tobacco"
    end
    if rnd == 4 then
        return "You wouldn't mind a smoke right now"
    end
end

--Put this function into an items on_use to give it nicotine properties
function tb_nicotine(player, chance, effect)
    local stop = player
    local pmeta = player:get_meta()
    local hp = player:get_hp()
    playerphysics.add_physics_factor(player, "speed", "civtobacco", effect)
    pmeta:set_int("civtobacco:nicotine_time", os.time()) --Sets time of last fix
    pmeta:set_string("civtobacco:nicotine_fix", "not") --Got fix
    --Random chance to become addicted. Varies with effect
    if math.random(1, 100) <= chance then
        --minetest.chat_send_all("nicotine very oof")
        player:set_hp(hp - (3 + effect))
        pmeta:set_string("civtobacco:nicotine", "depend")
    else
    minetest.after(300, function(stop) --Stops forever speed boost
	    playerphysics.remove_physics_factor(player, "speed", "civtobacco")
    end)
        --minetest.chat_send_all("nicotine not oof")
    end
end

--This checks if a certain amount of time has passed since last fix
function tb_checkfix(player)
    local pmeta = player:get_meta()
    local elapsed = pmeta:get_int("civtobacco:nicotine_time") - os.time()
    if (elapsed <= -300) then
        pmeta:set_string("civtobacco:nicotine_fix", "need")
    end
    --minetest.chat_send_all(elapsed)
end

--Randomly sets hunger down
function hunger_spike(player)
    local inv = player:get_inventory()
    local name = player:get_player_name()
    local value = hbhunger.hunger[name] + math.random(-9, -1)
    if value > 30 then
        value = 30
    end
    if value < 0 then
        value = 0
    end
    hbhunger.hunger[name] = value
end

--Give butts back from cigars,beedi ect
function givebutt(player)
    local inv = player:get_inventory()
    inv:add_item("main", "civtobacco:cigbutt")
end

--Stops players being addicted after death
minetest.register_on_respawnplayer(
    function(player)
        local pmeta = player:get_meta()
        pmeta:set_string("civtobacco:nicotine", "not")
    end
)

--Crafting recipes
--"Cook" leaves into cured versions for crafting
minetest.register_craft(
    {
        type = "cooking",
        output = "civtobacco:plant_cured",
        recipe = "civtobacco:plant",
        cooktime = 30
    }
)

-- Recipe for the cigarette
minetest.register_craft(
    {
        type = "shaped",
        output = "civtobacco:cigarette",
        recipe = {
            {"civtobacco:filter", "group:nicotine_raw", "civtobacco:paper"},
            {"", "", ""},
            {"", "", ""}
        }
    }
)

-- Recipe for the cigarette
minetest.register_craft(
    {
        type = "shaped",
        output = "civtobacco:beedi",
        recipe = {
            {"group:food_spice", "group:nicotine_raw", "farming:string"},
            {"", "", ""},
            {"", "", ""}
        }
    }
)

-- Recipe for the cigar
minetest.register_craft(
    {
        type = "shaped",
        output = "civtobacco:cigar",
        recipe = {
            {"default:paper", "group:nicotine_raw", "group:nicotine_raw"},
            {"", "", ""},
            {"", "", ""}
        }
    }
)

-- Recipe for the cigar(using flax based paper)
minetest.register_craft(
    {
        type = "shaped",
        output = "civtobacco:cigar",
        recipe = {
            {"civtobacco:paper", "group:nicotine_raw", "group:nicotine_raw"},
            {"", "", ""},
            {"", "", ""}
        }
    }
)

-- Recipe for the cigarette filter
minetest.register_craft(
    {
        type = "shapeless",
        output = "civtobacco:filter 3",
        recipe = {
            "farming:cotton",
            "default:limestone_dust"
        }
    }
)

-- Recipe for the cigarette paper
minetest.register_craft(
    {
        type = "shapeless",
        output = "civtobacco:paper 3",
        recipe = {
            "farming:flax",
            "default:paper"
        }
    }
)

-- Recipe for the snuff
minetest.register_craft(
    {
        type = "shapeless",
        output = "civtobacco:snuff",
        recipe = {
            "civtobacco:plant_cured"
        }
    }
)

-- Recipe using three cigarette butts to make a cigarette
minetest.register_craft(
    {
        type = "shapeless",
        output = "civtobacco:plant_cured",
        recipe = {
            "civtobacco:cigbutt",
            "civtobacco:cigbutt",
            "civtobacco:cigbutt"
        }
    }
)

-- Recipe to make seeds
minetest.register_craft(
    {
        type = "shapeless",
        output = "civtobacco:seed_leaves 2",
        recipe = {
            "civtobacco:plant"
        }
    }
)
--Enable tobacco to exist by making it drop from grass
for i = 1, 3 do
    minetest.override_item(
        "default:marram_grass_" .. i,
        {
            drop = {
                max_items = 1,
                items = {
                    {items = {"civtobacco:seed_plant"}, rarity = 10},
                    {items = {"default:marram_grass_1"}}
                }
            }
        }
    )
end

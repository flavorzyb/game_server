%%% Generated by generate_config.rake 
-record(config_alliance_donations, {
        donate_type,
        cost,
        rewards,
        dkp,
        founds,
        prestige}).

-record(config_alliance_researches, {
        conf_id,
        level,
        name,
        founds}).

-record(config_alliance_upgrades, {
        level,
        founds}).

-record(config_unlock_alliance_researches, {
        name,
        level}).

-record(config_alliance_activities, {
        conf_id,
        category,
        event_id,
        name,
        frequence,
        start,
        duration,
        founds,
        unlock}).

-record(config_alliance_bosses, {
        conf_id,
        boss_name,
        founds,
        delay,
        duration,
        hp,
        power_atk,
        boss_drop,
        first_rewards,
        reward_rank_1,
        reward_rank_2,
        reward_rank_3,
        reward_rank_4,
        reward_rank_5,
        reward_rank_6_10,
        reward_rank_11_20}).

-record(config_arena_groups, {
        level,
        group,
        score,
        k_factor,
        daily_rewards}).

-record(config_battles, {
        battle_id,
        monster_groups,
        exp,
        money,
        loot,
        rewards_limit,
        ap}).

-record(config_monstergroups, {
        conf_id,
        batt_img,
        batt_desc,
        formation,
        is_boss}).

-record(config_buffs, {
        buff_id,
        buff_round,
        buff_prob,
        energy,
        hp,
        attack,
        physic_defense,
        magic_defense,
        recover,
        skill_power,
        crit,
        crit_damage,
        anti_crit,
        accurate,
        dodge,
        parry,
        penetration,
        block,
        speed}).

-record(config_game_consts, {
        key,
        data}).

-record(config_equips, {
        equip_id,
        equip_icon,
        equip_type,
        req_lv,
        req_jobs,
        health,
        attack,
        physic_defense,
        magic_defense,
        recover,
        skill_power,
        crit,
        crit_damage,
        anti_crit,
        accurate,
        dodge,
        parry,
        penetration,
        block,
        speed,
        back_soul,
        price,
        equip_quality}).

-record(config_forges, {
        equip_id,
        health,
        attack,
        physic_defense,
        magic_defense,
        recover,
        skill_power,
        crit,
        crit_damage,
        anti_crit,
        accurate,
        dodge,
        parry,
        penetration,
        block,
        speed}).

-record(config_forge_requirements, {
        equip_id,
        soul,
        money,
        raise_soul,
        raise_money,
        cri_rate,
        bcri_rate,
        level_limit}).

-record(config_equip_evolves, {
        equip_id,
        target_equip_id,
        reduce_level,
        requirements,
        pow_low,
        pow_mid,
        mid_area,
        pow_high,
        high_area,
        pow_super,
        super_area}).

-record(config_error_msgs, {
        name,
        no}).

-record(config_gemstone_bases, {
        gemstone_id,
        name,
        color,
        level,
        cost,
        atk,
        hp,
        dodge,
        advance,
        advance_id}).

-record(config_gemstone_slots, {
        slot_id,
        color,
        addition,
        unlock_star}).

-record(config_gem_combines, {
        gem_ids,
        target_id}).

-record(config_hero_exps, {
        level,
        exp}).

-record(config_player_exps, {
        level,
        exp,
        max_ap,
        max_soul}).

-record(config_hero_evolves, {
        star,
        next_fragments,
        max_fragments,
        attribute_up}).

-record(config_players, {
        config_id,
        star,
        name,
        name_desc,
        character_file,
        profession,
        skill_ids,
        attack_type,
        hp,
        attack,
        physic_defense,
        magic_defense,
        skill_power,
        crit,
        crit_damage,
        anti_crit,
        accurate,
        dodge,
        penetration,
        block,
        speed,
        damage_fix,
        can_sell,
        gem_slot,
        lottery_soul,
        equip}).

-record(config_player_grows, {
        config_id,
        name,
        name_desc,
        hp,
        attack,
        physic_defense,
        magic_defense,
        skill_power,
        crit,
        crit_damage,
        anti_crit,
        accurate,
        dodge,
        penetration,
        block,
        speed}).

-record(config_items, {
        item_id,
        icon,
        item_type,
        auction_price,
        item_name,
        item_func_describe,
        item_describe,
        effect,
        rank,
        recycle_price}).

-record(config_item_compositions, {
        conf_id,
        materials,
        item}).

-record(config_markets, {
        item_id,
        price}).

-record(config_alliance_stores, {
        item_id,
        price,
        amount,
        unlock_level,
        amount_up}).

-record(config_monsters, {
        conf_id,
        character_file,
        job,
        level,
        atk_type,
        shape,
        skill_power,
        hp,
        attack,
        physic_defense,
        magic_defense,
        crit,
        crit_damage,
        anti_crit,
        accurate,
        dodge,
        penetration,
        block,
        speed,
        damage_fix,
        skill_ids,
        soul,
        money}).

-record(config_prestiges, {
        prestige_id,
        prestigeup_exp,
        prestige_reward,
        soul_max,
        daily_prestige}).

-record(config_quests, {
        task_id,
        category,
        unlock,
        condition,
        rewards,
        name,
        desc}).

-record(config_waypoints, {
        conf_id,
        wp_type,
        event_id,
        area,
        next_map_points,
        unlock_ability,
        befor_dialog_id,
        victor_dialog_id,
        after_dialog_id,
        level_need}).

-record(config_copies, {
        conf_id,
        copy_id,
        event_id,
        wp_type,
        next_map_points,
        isboss,
        is_elite,
        befor_dialog_id,
        victor_dialog_id,
        after_dialog_id,
        level_need,
        is_last,
        monseter,
        monseter_level,
        monseter_force,
        ap}).

-record(config_mapinfos, {
        conf_id,
        map_file,
        map_name,
        map_desc}).

-record(config_daily_awards, {
        days,
        awards}).

-record(config_sublv_awards, {
        level,
        awards}).

-record(config_keepol_awards, {
        duration,
        awards}).

-record(config_skills, {
        skill_id,
        name,
        desc,
        toplevel,
        unlock_star,
        levelrate,
        base_consume,
        targets_find_type,
        damage_type,
        damage_rate,
        damage_range,
        damage_fix,
        dodge_able,
        block_able,
        crit_able,
        fightback_able,
        defense_able,
        fury_able,
        is_special,
        effect_attack,
        effect_hurt,
        type,
        add}).

-record(config_pushes, {
        conf_id,
        cn,
        en}).

-record(config_system_messages, {
        conf_id,
        cn,
        en}).

-record(config_item_names, {
        conf_id,
        cn,
        en}).

-record(config_lotteries, {
        id,
        rare,
        category,
        conf_id,
        rate}).

-record(config_terrains, {
        conf_id,
        desc,
        attack,
        defend}).

-record(config_formation_unlocks, {
        formation_id,
        level,
        req_lv,
        formation}).


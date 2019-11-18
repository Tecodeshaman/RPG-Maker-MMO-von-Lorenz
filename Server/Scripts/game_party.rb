#==============================================================================
# ** Game_Party
#------------------------------------------------------------------------------
#  Este módulo lida com o grupo.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module Game_Party

	attr_accessor :party_id
	
	def party_members_in_map
		$server.parties[@party_id].select { |member| member.map_id == @map_id }
	end

	def party_share(exp, gold, enemy_id)
		party_members = party_members_in_map
		party_share_exp(exp, enemy_id, party_members)
		party_share_gold(gold, party_members)
	end

	def party_share_exp(exp, enemy_id, party_members)
  	if party_members.size > exp || party_members.size == 1
			gain_exp(exp)
			add_kills_count(enemy_id)
    	return
		end
		exp_share = exp / party_members.size + (exp * PARTY_BONUS[party_members.size] / 100)
		dif_exp = exp - exp_share * party_members.size
		party_members.each do |member|
			member.gain_exp(member == self ? exp_share + dif_exp : exp_share)
			member.add_kills_count(enemy_id)
		end
	end

	def party_share_gold(gold, party_members)
		if party_members.size > gold || party_members.size == 1
			gain_gold(gold, false, true)
			return
		end
		gold_share = gold / party_members.size + (gold * PARTY_BONUS[party_members.size] / 100)
		party_members.each { |member| member.gain_gold(gold_share, false, true) }
	end
	
	def item_party_recovery(item)
		unless in_party?
			item_recover(item)
			return
		end
		party_members_in_map.each do |member|
			member.item_recover(item)
    end
  end
  
	def accept_party
		return if in_party?
		if $server.clients[@request.id].in_party?
			return if $server.parties[$server.clients[@request.id].party_id].size >= Configs::MAX_PARTY_MEMBERS
    	@party_id = $server.clients[@request.id].party_id
  	else
			create_party
		end
		$server.parties[@party_id].each do |member|
			$server.send_join_party(member, self)
			$server.send_join_party(self, member)
		end
		$server.parties[@party_id] << self
	end
	
	def create_party
		@party_id = $server.find_empty_party_id
		$server.clients[@request.id].party_id = @party_id
		$server.parties[@party_id] = [$server.clients[@request.id]]
	end

	def leave_party
		return unless in_party?
		$server.send_dissolve_party(self)
		$server.parties[@party_id].delete(self)
		if $server.parties[@party_id].size == 1
			dissolve_party($server.parties[@party_id].first)
		else
			$server.send_leave_party(self)
		end
		@party_id = -1
	end

	def dissolve_party(party_member)
		$server.parties[@party_id] = nil
		$server.party_ids_available << @party_id
		$server.send_dissolve_party(party_member)
		party_member.party_id = -1
	end

end

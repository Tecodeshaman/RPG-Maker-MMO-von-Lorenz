#==============================================================================
# ** Game_Account
#------------------------------------------------------------------------------
#  Este módulo lida com a conta.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

module Game_Account

  attr_reader   :id
	attr_reader   :ip
	attr_writer   :handshake
  attr_accessor :user
  attr_accessor :pass
  attr_accessor :email
	attr_accessor :group
	attr_accessor :vip_time
	attr_accessor :actors

  def init_basic
		@id = -1
		@user = ''
		@pass = ''
		@email = ''
		@group = 0
		@actor_id = -1
		@actors = {}
		@vip_time = nil
		@handshake = false
		@hand_time = Time.now + AUTHENTICATION_TIME
		@ip = Socket.unpack_sockaddr_in(get_peername)[1]
  end

	def connected?
		@id >= 0
	end

	def logged?
		!@user.empty?
	end

	def in_game?
		@actor_id >= 0
	end

	def standard?
		@group == Constants::GROUP_STANDARD
	end
	
	def admin?
		@group == Constants::GROUP_ADMIN
	end

	def monitor?
		@group == Constants::GROUP_MONITOR
	end

	def vip?
		@vip_time > Time.now
	end

	def actor
		@actors[@actor_id]
	end

	def add_vip_days(days)
		# Executa a mensagem com a quantidade de dias antes da conversão
		$server.player_message(self, sprintf(AddVipDays, days), Configs::SUCCESS_COLOR)
		days = days * 86400
		@vip_time = [@vip_time + days, Time.now + days].max
		$server.send_vip_days(self)
		Database.save_account(self)
	end
  
	def post_init
		if $server.full_clients?
			$server.send_failed_login(self, Constants::LOGIN_SERVER_FULL)
			puts("Client with IP #{@ip} tried to connect!")
			disconnect
		elsif $server.banned?(@ip)
			$server.send_failed_login(self, Constants::LOGIN_IP_BANNED)
			puts("Client with banned IP #{@ip} tried to connect!")
			disconnect
		#elsif $server.multi_ip_online?(@ip)
			#$server.send_failed_login(self, Constants::LOGIN_MULTI_IP)
			#puts("Client with IP #{@ip} already in use tried to connect!")
			#disconnect
		else
			@id = $server.find_empty_client_id
			$server.connect_client(self)
		end
	end

	def unbind
		leave_game if in_game?
		$server.disconnect_client(@id) if connected?
	end

	def disconnect
		# Espera 100 milissegundos para desconectar
		EventMachine::Timer.new(0.1) { close_connection }
	end

	def receive_data(data)
		buffer = Binary_Reader.new(data)
		count = 0
		while buffer.can_read? && count < 25
			$server.handle_messages(self, buffer)
			count += 1
		end
	end

	def load_data(actor_id)
		@name = @actors[actor_id].name
		@character_name = @actors[actor_id].character_name
		@character_index = @actors[actor_id].character_index
		@face_name = @actors[actor_id].face_name
		@face_index = @actors[actor_id].face_index
		@class_id = @actors[actor_id].class_id
		@sex = @actors[actor_id].sex
		@level = @actors[actor_id].level
		@exp = @actors[actor_id].exp
		@hp = @actors[actor_id].hp
		@mp = @actors[actor_id].mp
		@param_base = @actors[actor_id].param_base
		@equips = @actors[actor_id].equips
		@points = @actors[actor_id].points
		@revive_map_id = @actors[actor_id].revive_map_id
		@revive_x = @actors[actor_id].revive_x
		@revive_y = @actors[actor_id].revive_y
		@map_id = @actors[actor_id].map_id
		@x = @actors[actor_id].x
		@y = @actors[actor_id].y
		@direction = @actors[actor_id].direction
		@gold = @actors[actor_id].gold
		@items = @actors[actor_id].items
		@weapons = @actors[actor_id].weapons
		@armors = @actors[actor_id].armors
		@skills = @actors[actor_id].skills
		@quests = @actors[actor_id].quests
		@friends = @actors[actor_id].friends
		@hotbar = @actors[actor_id].hotbar
		@switches = @actors[actor_id].switches
		@variables = @actors[actor_id].variables
		@self_switches = @actors[actor_id].self_switches
	end

	def join_game(actor_id)
		@actor_id = actor_id
		@recover_time = Time.now + RECOVER_TIME
		@weapon_attack_time = Time.now
		@item_attack_time = Time.now
		@antispam_time = Time.now
		@muted_time = Time.now
		@stop_count = Time.now
		@online_friends_size = 0
		@teleport_id = -1
		@party_id = -1
		@shop_goods = nil
		@choices = nil
		clear_target
		clear_request
	end

	def leave_game
		save_data
		# Retira da lista de clientes no jogo
		@actor_id = -1
		$server.maps[@map_id].total_players -= 1
		$server.send_remove_player(@id, @map_id)
		clear_target_players(Constants::TARGET_PLAYER)
		$server.global_message("#{@name} #{Exited}", Configs::ALERT_COLOR)
		close_trade
		leave_party
	end

	def save_data
		actor.character_name = @character_name
		actor.character_index = @character_index
		actor.face_name = @face_name
		actor.face_index = @face_index
		actor.class_id = @class_id
		actor.level = @level
		actor.exp = @exp
		actor.hp = @hp
		actor.mp = @mp
		actor.param_base = @param_base
		actor.equips = @equips
		actor.points = @points
		actor.revive_map_id = @revive_map_id
		actor.revive_x = @revive_x
		actor.revive_y = @revive_y
		actor.map_id = @map_id
		actor.x = @x
		actor.y = @y
		actor.direction = @direction
		actor.gold = @gold
		actor.items = @items
		actor.weapons = @weapons
		actor.armors = @armors
		actor.skills = @skills
		actor.quests = @quests
		actor.friends = @friends
		actor.hotbar = @hotbar
		actor.switches = @switches
		actor.variables = @variables
		actor.self_switches = @self_switches
		Database.save_player(actor)
		Database.save_bank(self)
	end

	def update_menu
		close_connection if !@handshake && Time.now > @hand_time
	end

end

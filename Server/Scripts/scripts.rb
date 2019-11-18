#==============================================================================
# ** Scripts
#------------------------------------------------------------------------------
#  Executa os scripts do cliente Configs e Quests.
#------------------------------------------------------------------------------
#  Autor: Valentine
#==============================================================================

class Font

	def self.default_name=(name)
	end
	
	def self.default_outline=(name)
	end

	def self.default_shadow=(name)
	end

  def self.default_bold=(bold)
  end

  def self.default_italic=(italic)
  end

  def self.default_color=(color)
	end
	
  def self.default_size=(size)
  end
	
end

class Color

  def initialize(red, green, blue, alpha = 255)
	end
	
end

scripts = load_data('Scripts.rvdata2')
# Executa os scripts Configs e Quests
eval(Zlib::Inflate.inflate(scripts[1][2]))
eval(Zlib::Inflate.inflate(scripts[2][2]))

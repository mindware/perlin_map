require 'perlin_noise'
require 'chunky_png'
require 'colorize'
require 'time'

def biome(elevation, moisture)
  return :ocean if elevation < 0.1
  return :beach if elevation < 0.12
 
  if elevation > 0.9
    return :scorched if moisture < 0.1
    return :bare     if moisture < 0.2
    return :tundra   if moisture < 0.5
    return :snow 
  end

  if elevation > 0.6
    return :desert      if moisture < 0.33 
    return :shrubland   if moisture < 0.66
    return :taiga       if moisture < 0.94
    return :mudland     if moisture < 0.95
    return :water
  end
  
  if elevation > 0.3
    return :desert      if moisture < 0.16
    return :grassland   if moisture < 0.50
    return :forest      if moisture < 0.83
    return :rainforest  if moisture < 0.93
    return :mudland     if moisture < 0.95
    return :water      
  end
  return :desert              if moisture < 0.16
  return :grassland           if moisture < 0.33
  return :forest              if moisture < 0.66
  return :rainforest          if moisture < 0.90
  return :water
end

def pixel(value)
  case value.to_sym 
    when :snow
      return ['"'.light_white, "white"]
    when :ocean
      return ["~".blue, "darkblue"]
    when :water 
      return ["~".colorize(:light_blue), "cyan"]
    when :beach
      return [":".colorize(:yellow).on_light_yellow, "lightgoldenrodyellow"]
    when :scorched
      return ["~".colorize(:red), "red"]
    when :bare
      return [".".light_yellow.on_red, "orange"]
    when :desert
      return [".".colorize(:yellow).on_light_yellow, "yellow"]
    when :tundra
      return [".".colorize(:grey).on_white, "grey"]
    when :shrubland
      return [".".colorize(:green).on_light_green, "forestgreen"]
    when :taiga
      return [".".colorize(:black).on_green, "darkgreen"]
    when :mudland
      return [" ".on_yellow, "brown"]
    when :grassland
      return [".".colorize(:green), "springgreen"]
    when :forest
      return ["*".on_green, "green"]
    when :rainforest
      return ["*".colorize(:light_green), "greenyellow"]
    else
      return ["&".red, "red"]
  end
end

#############################
#         Setup:            #
#############################

# For deterministic maps:
use_seed = true
elevation_seed = 461924219817459
elevation_seed = 385466685891077
elevation_seed = 643795881105811

moisture_seed  = 120398471230987
moisture_seed  = 928097657486672

# Perlin Noise Layers setup:
increase_noise_contrast = true
limit = 0.1

# Perlin Noise and PNG Image setup:
width, height  = 256, 256

# PNG Image setup:
png = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color::WHITE)
image_name = Time.now.utc.iso8601.to_s.gsub(":", "-")

# For metrics:
count = 0
highest, lowest = 0,1

#############################
#  Random vs Deterministic: #
#############################
if use_seed
  puts "Using hard-coded seeds: "+
       "(elevation: #{elevation_seed}) "+
       "(moisture: #{moisture_seed})"
  elevation = Perlin::Noise.new 2, :seed => elevation_seed
  moisture  = Perlin::Noise.new 2, :seed => moisture_seed
else
  elevation_seed = rand(100000000000000..999999999999999)
  moisture_seed  = rand(100000000000000..999999999999999)
  puts "Generated random seeds: "+
       "(elevation: #{elevation_seed}) "+
       "(moisture: #{moisture_seed})"
  elevation = Perlin::Noise.new 2, :seed => elevation_seed
  moisture  = Perlin::Noise.new 2, :seed => moisture_seed
end

puts "Image: map.png (#{width} x #{height})"

contrast = Perlin::Curve.contrast(Perlin::Curve::CUBIC, 2) if increase_noise_contrast
(height).times do |y|
  (width).times do |x|
    e = elevation[x * limit, y * limit]
    m = moisture[x * limit, y * limit]
    # get biome for coordinate point
    point = pixel(biome(contrast.call(e), contrast.call(m)))
    # print ascii:
    print point[0]
    # print image with coords as pixel:
    color = ChunkyPNG::Color("#{point[1]} @ 1.0")
    png[x,y] = color

    # metrics:
    lowest  = elevation[x,y] if elevation[x,y] < lowest
    highest = elevation[x,y] if elevation[x,y] > highest
    count += 1
  end
  puts ""
end

puts "\ncount: #{count}\thigh: #{highest}\tlow: #{lowest}"

# Creating an image from scratch, save as an interlaced PNG
png.save("images/#{image_name}.png", :interlace => true)
system("xdg-open images/#{image_name}.png")

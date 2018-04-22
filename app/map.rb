require 'perlin_noise'
require 'chunky_png'
require 'colorize'
require 'time'

def biome(elevation, moisture)
  return :ocean if elevation <= 0.35
  return :water if elevation <= 0.53
  return :beach if elevation <= 0.60
 
  if elevation > 0.95
    return :scorched if moisture < 0.002
    return :bare     if moisture < 0.005
    return :forest   if moisture < 0.6
    return :tundra   if moisture < 0.7
    return :snow 
  end

  if elevation > 0.85
    return :desert      if moisture < 0.10 
    return :shrubland   if moisture < 0.30
    return :grassland   if moisture < 0.50
    return :dark_forest if moisture < 0.85
    return :taiga       if moisture < 0.95
    return :water
  end
  
  if elevation > 0.75
    return :desert      if moisture < 0.15
    return :grassland   if moisture < 0.60
    return :forest      if moisture < 0.83
    return :rain_forest if moisture < 0.95
    return :mudland     if moisture < 0.96
    return :water      
  end
  if elevation > 0.53
    return :desert              if moisture < 0.10
    return :grassland           if moisture < 0.40
    return :mudland             if moisture < 0.42
    return :tropical_forest     if moisture < 0.60
    return :rain_forest          if moisture < 0.95
    return :water
  end 
  
  puts "#{elevation}".red.on_white
  return :error 
end

def pixel(value)
  case value.to_sym 
    when :snow
      return ['"'.light_white, "white"]
    when :ocean
      return ["~".blue, "darkblue"]
    when :water 
      return ["~".colorize(:light_blue), "blue"]
    when :beach
      return [".".colorize(:light_yellow), "lightgoldenrodyellow"]
    when :scorched
      return [".".yellow.on_red, "orangered"]
    when :bare
      return [".".light_yellow.on_red, "orange"]
    when :desert
      return [".".light_yellow.on_yellow, "yellow"]
    when :tundra
      return [" ".on_light_black, "grey"]
    when :shrubland
      return [".".colorize(:green).on_light_green, "forestgreen"]
    when :taiga
      return [".".colorize(:black).on_green, "darkgreen"]
    when :mudland
      return [" ".on_yellow, "brown"]
    when :grassland
      return [".".light_yellow.on_light_green, "springgreen"]
    when :rain_forest
      return [" ".on_green, "greenyellow"]
    when :forest
      return ["*".black.on_green, "green"]
    when :dark_forest
      return ["*".green.on_black, "darkgreen"]
    when :tropical_forest
      return ["*".light_green.on_green, "greenyellow"]
    else
      return ["&".white.on_red, "red"]
  end
end

def percentage(number, original)
   number = number.to_f
   original = original.to_f
   return ((number - original) / original) * 100
end

#############################
#         Setup:            #
#############################

# For deterministic maps:
use_seed = true
#elevation_seed = 461924219817459
#elevation_seed = 385466685891077
#elevation_seed = 643795881105811
elevation_seed = 445123488693448

#moisture_seed  = 120398471230987
#moisture_seed  = 928097657486672
moisture_seed  = 995732500100045

# Perlin Noise Layers setup:
contrast_increase = 2
#limit = 0.009
limit = 0.0005

# Perlin Noise and PNG Image setup:
# width, height  = 256, 256
#width, height  = 16, 16
#width, height  = 4096, 2048
width, height  = 2048, 1024
zoom = 1

# Image transparency 
transparency = 1.0

# Map Offset:
#offset_y = width / 2
#offset_y = width / 2
offset_y = 0
offset_x = 0 

#width, height  = 2048, 2048

# For metrics:
count = 0
highest, lowest = -1.0,1.0

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

# PNG Image setup:
if zoom > 0
  png = ChunkyPNG::Image.new(width * zoom, height * zoom, ChunkyPNG::Color::WHITE)
  puts "Image: map.png (#{width * zoom} x #{height * zoom})"
else
  png = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color::WHITE)
  puts "Image: map.png (#{width} x #{height})"
end

image_name = Time.now.utc.iso8601.to_s.gsub(":", "-")
image_name += "#{elevation_seed}-#{moisture_seed}.png"

contrast = Perlin::Curve.contrast(Perlin::Curve::CUBIC, contrast_increase) 
(height).times do |y|
  (width).times do |x|
    xx, yy = x + offset_x, y + offset_y

    e = elevation[xx * limit, yy * limit]
    m = moisture[xx * limit, yy * limit]
    # get biome for coordinate point
    point = pixel(biome(contrast.call(e), contrast.call(m)))
    # ascii version: 
    #print point[0]
    # print image with coords as pixel:
    color = ChunkyPNG::Color("#{point[1]} @ #{transparency}")
    if(zoom > 0)
      (0..(zoom - 1)).each do |zi|
        (0..(zoom - 1)).each do |zj|
          count += 1
          zy = (y * zoom) + zi
          zx = (x * zoom) + zj
          png[zx,zy] = color
        end
      end 
    else
      count += 1
      png[x,y] = color
    end
    #print "\t"
    # metrics:
    lowest  = elevation[xx,yy] if elevation[xx,yy] < lowest
    highest = elevation[xx,yy] if elevation[xx,yy] > highest
    printf("\rPercentage: %d (#{count})", percentage(count, (width + height)))
  end
end

puts "\ncount: #{count}\thigh: #{highest}\tlow: #{lowest}"
puts "Elevation seed: #{elevation_seed}\tMoisture seed: #{moisture_seed}"

# Creating an image from scratch, save as an interlaced PNG
png.save("images/#{image_name}", :interlace => true)
system("xdg-open images/#{image_name}")

require 'English'
require 'benchmark'
require 'pp'

def pp_solution(solution)
  if solution.empty?
    puts 'No solution'
  else
    puts solution.map { |_, _, w, h| "#{w}x#{h}" } * ', '
  end
end

def pp_slices(pie, solution)
  if solution.empty?
    puts 'No solution'
  else
    slices = solution.map do |x, y, w, h|
      pie.lines[y...y + h].map { |line| line[x...x + w] } * "\n"
    end

    PP.pp slices, $DEFAULT_OUTPUT, 0
  end
end

def slice_pie(pie)
  h = pie.lines.length
  w = pie.lines[0].chomp.length

  cherries_count = pie.chars.count 'o'

  return [] if cherries_count == 0 || w * h % cherries_count != 0

  area = w * h / cherries_count

  sizes = (1..area).filter { |h1| area % h1 == 0 }.to_a

  cherries = (0...w).to_a.product((0...h).to_a).filter { |x, y| pie.lines[y].chars[x] == 'o' }

  stack = []

  slice_sub w, h, area, sizes, cherries, stack, 0, 0

  stack
end

def slice_sub(width, height, area, sizes, cherries, stack, x, y)
  sizes.each do |h|
    break if y + h > height

    w = area / h

    next if x + w > width

    next unless cherries.one? { |x1, y1| x <= x1 && x1 < x + w && y <= y1 && y1 < y + h }

    stack << [x, y, w, h]

    xy = find_next_xy stack, x + w, y, width, height

    return true if xy.nil?

    r = slice_sub width, height, area, sizes, cherries, stack, *xy

    return true if r

    stack.pop
  end

  false
end

def find_next_xy(stack, x, y, width, height)
  return [x, y] if x < width

  loop do
    if x == width
      y += 1

      return nil if y == height

      x = 0
    end

    rect = stack.find { |x1, y1, w, h| y1 <= y && y < y1 + h && x1 <= x && x < x1 + w }

    return [x, y] if rect.nil?

    x += rect[2]
  end
end

raise unless slice_pie('.').empty?
raise unless slice_pie('oo.').empty?
raise unless slice_pie('oo..').empty?
raise unless slice_pie('o') == [[0, 0, 1, 1]]
raise unless slice_pie('oo') == [[0, 0, 1, 1], [1, 0, 1, 1]]
raise unless slice_pie('o..o') == [[0, 0, 2, 1], [2, 0, 2, 1]]

pie = ".o.o....\n"\
      "........\n"\
      "....o...\n"\
      "........\n"\
      ".....o..\n"\
      '........'

puts 'Pie:', pie, ''

solution = slice_pie pie

p solution

pp_solution solution
pp_slices pie, solution

require 'net/http'
require 'open-uri'
$file_types = %w[html php css txt doc jpg jpeg png gif bmp tif tiff docx pdf rtf odt csv xls xlsx json xml yaml sqlite zip rar 7z tar gz bz2 exe msi bat sh jar py rb cpp c pl ttf otf svg dwg obj max fbx obj ma bm blend mp3 wav aac wma mkv webp webm]
if ARGV.empty?
  puts colorize '请在命令行调用', COLOR_RED
  exit!
end

class DownloaderMain
  def get_command_line_arguments
    @@command_line_arguments = ARGV[0]
  end

  def get_suffix
    # 解析URL
    uri = URI.parse(@@command_line_arguments)
    # 获取路径的最后一部分
    path = File.basename(uri.path)
    # 获取扩展名
    File.extname(path)
  end

  DownloaderMain.new.get_command_line_arguments
  @@suffix = DownloaderMain.new.get_suffix[1..-1]

  def doanload_start_main
    if $file_types.include?(@@suffix)
      puts colorize('开始下载', COLOR_GREEN)
      download_start(@@command_line_arguments)
    else
      puts colorize('暂不支持该文件类型', COLOR_RED)
      exit!
    end
  end

  def download_start(url)
    filename = File.basename(url)

    uri = URI.parse(url)

    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new uri

      http.request(request) do |response|
        open filename, 'wb' do |file|
          response.read_body do |chunk|
            file.write(chunk)
          end
        end
      end
    end
  end
end

class String
  def is_url?
    pattern = %r{^((https|http|ftp|rtsp|mms)?://)[^\s]+}
    (pattern =~ self) == 0
  end
end

def colorize(text, color_code)
  "\e[#{color_code}m#{text}\e[0m"
end

COLOR_RED = 31
COLOR_GREEN = 32

download_main = DownloaderMain.new
download_url = download_main.get_command_line_arguments
if download_main.get_command_line_arguments.is_url? == true
  puts colorize('URL TRUE', COLOR_GREEN)
  puts colorize("Suffix:#{download_main.get_suffix[1..-1]}", COLOR_GREEN)
  $size = 0
  URI.open(download_url) do |file|
    $size = file.size
  end
  if $size > 1024 * 1024 * 1024
    $size = $size / 1024.0 / 1024.0 / 1024.0
    $size = sprintf("%.2f", $size)
    $size = "#{$size.to_s}GB"
  elsif $size > 1024 * 1024
    $size = $size / 1024.0 / 1024.0
    $size = sprintf("%.2f", $size)
    $size = "#{$size.to_s}MB"
  elsif $size > 1024
    $size = $size / 1024.0
    $size = sprintf("%.2f", $size)
    $size = "#{$size.to_s}KB"
  else
    $size = "#{$size.to_s}K"
  end
  puts "文件名:#{File.basename(download_url)}\n文件大小:#{$size.to_s}"
  puts '是否下载该文件?[Y/N]'
  input = STDIN.gets.chomp.strip
  if input == 'Y' or input == 'y'
    download_main.doanload_start_main
  elsif input == 'N' or input == 'n'
    puts colorize('下载已退出', COLOR_RED)
    exit!
  else
    puts colorize('下载已退出', COLOR_RED)
    exit!
  end
  puts colorize('下载完成', COLOR_GREEN)
else
  puts colorize('URL FALSE', COLOR_RED)
  exit!
end
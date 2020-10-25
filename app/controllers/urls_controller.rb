# frozen_string_literal: true

class UrlsController < ApplicationController

  # base url
  @@base_url = 'http://localhost:3000'
  def index
    @url = Url.new
    @urls = Url.all.order("created_at DESC").limit(10) 
  end

  def create
    @url = Url.find_by(original_url: params[:url][:original_url])
    
    if @url
      redirect_to url_path(@url[:short_url]), notice: 'Link successfuly shorted'
    else
      random_code = SecureRandom.uuid62
      
      @code = Url.find_by(short_url: random_code)
      
      while @code != nil
        random_code = SecureRandom.uuid62
        
        @code = Url.find_by(short_url: random_code[0...5])
      end

      if @code == nil
        @url = Url.new(original_url: params[:url][:original_url], short_url: random_code[0...5], created_at: Time.now)
        
        p @url
        
        if @url.valid?
          if @url.save
            p @url[:short_url]
            redirect_to url_path(@url[:short_url]), notice: 'Link successfuly shorted'
          else
              render 'index', notice: 'somenthing went wrong'
          end
        else
          redirect_to urls_path(), notice: 'The URL is not valid! Please try again'
        end 
      end

    end
    
   
  end

  def show
    @url = Url.find_by(short_url: params[:url])
    
    count_browser = count_browsers(@url)
    count_platform = count_platform(@url)

    p "count browser: #{count_browser}"
    p count_browser
    # implement queries
    @daily_clicks = [
      ['1', 13],
      ['2', 2],
      ['3', 1],
      ['4', 7],
      ['5', 20],
      ['6', 18],
      ['7', 10],
      ['8', 20],
      ['9', 15],
      ['10', 5]
    ]
    @browsers_clicks = [
      ['IE', count_browser[:count_ie]],
      ['Firefox', count_browser[:count_firefox]],
      ['Chrome', count_browser[:count_chrome]],
      ['Safari', count_browser[:count_safari]]
    ]
    @platform_clicks = [
      ['Windows', count_platform[:count_windows]],
      ['macOS', count_platform[:count_mac]],
      ['Ubuntu', count_platform[:count_ubuntu]],
      ['Other', count_platform[:count_other]]
    ]
  end

  def visit
    shorted_url = params[:url]
    p shorted_url
    p 'the above is the shorted url'
    @url = Url.find_by(short_url: shorted_url)

    if @url
      p 'redirecting'
      browser_method @url
      redirect_to @url[:original_url]
    else
      p 'something went wrong redirecting'
    end
  end

  private


  def url_params
    params.require(:url).permit(:original_url)
  end

  def browser_method url
    p "user agent"
    p request.user_agent
    @browser = Browser.new(request.user_agent, accept_language: "en-us")
    
    modern_browser?(@browser, url)
  end
  

  def modern_browser?(browser, url)

    @count = url
    @count.clicks_count += 1
    @count.save

    @count.clicks.new(platform: browser.platform.name, browser: browser.name)

    if @count.save
      p "browser platform"
      p browser.platform.name
      p "browser name"
      p browser.name 
    end
  end

  def count_browsers(count)
    count_chrome = 0
    count_safari = 0
    count_firefox = 0
    count_ie = 0

    count.clicks.each do |click|
      if click.browser.downcase == 'chrome'
        count_chrome += 1
      elsif click.browser.downcase == 'safari'
        count_safari += 1
      elsif click.browser.downcase == 'firefox'
        count_firefox += 1
      elsif click.browser.downcase == 'ie'
        count_ie += 1
      end
    end

    @count_hash = {count_chrome: count_chrome, count_safari: count_safari, count_firefox: count_firefox, count_ie: count_ie}

  end

  def count_platform(count)
    count_windows = 0
    count_mac = 0
    count_ubuntu = 0
    count_other = 0

    count.clicks.each do |click|
      if click.platform.downcase == 'window'
        count_windows += 1
      elsif click.platform.downcase == 'macos'
        count_mac += 1
      elsif click.platform.downcase == 'ubuntu'
        count_ubuntu += 1
      else
        count_other += 1
      end
    end

    @count_hash = {count_windows: count_windows, count_mac: count_mac, count_ubuntu: count_ubuntu, count_other: count_other}

  end

end

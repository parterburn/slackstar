class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def root
    if params[:code].present?
      set_ss_token
      redirect_to root_path and return
    end
    if cookies[:ss_access_tokens].present?
      @teams = {}
      @all_tokens = JSON.parse(cookies[:ss_access_tokens].gsub('=>', ':'))
      @all_tokens.each do |token|
        response = list_stars(token.second, { count: (params[:count] || 1000), page: (params[:page] || 1) })
        if response.error
          @error = response.error
        else
          @teams[token.first] = response.items
        end
      end
    end
  end

  def clear
    cookies.delete :ss_access_tokens
    redirect_to root_path
  end

  private

  def set_ss_token
    client = Slack::Web::Client.new
    resp = client.oauth_access(client_id: ENV['SLACK_APP_CLIENT_ID'], client_secret: ENV['SLACK_APP_CLIENT_SECRET'], code: params[:code])
    if resp.ok == true
      all_tokens = cookies[:ss_access_tokens].present? ? JSON.parse(cookies[:ss_access_tokens].gsub('=>', ':')) : {}
      cookies[:ss_access_tokens] = {
        value: all_tokens.merge(resp.team_name => resp.access_token),
        expires: 1.year.from_now
      }
    end
  rescue Slack::Web::Api::Error
    @error = 'Slack token already used. Try again.'
  end

  def list_stars(token, options)
    client = Slack::Web::Client.new(token: token)
    client.stars_list(options)
  end
end

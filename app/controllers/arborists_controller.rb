require 'redmine_arborist/rebuilder'

class ArboristsController < ApplicationController
  #before_filter :authorize

  def rebuild
    result = RedmineArborist::Rebuilder.rebuild!(params[:type].constantize, params[:id])
    flash[:notice] = 'OK'
    redirect_to back_url
#  rescue
#    flash[:error] = 'failed'
#    redirect_to back_url
  end
end

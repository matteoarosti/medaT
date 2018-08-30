class SyncroFromMedaT < ApplicationController
  
  skip_before_action :authenticate_user!
  
  def test
    render json: {:success => true, :data=>{aaaaaa: 3333, params: params}}
  end   
  
end

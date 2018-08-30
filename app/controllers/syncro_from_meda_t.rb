class SyncroFromMedaT < ApplicationController
  
  def test
    render json: {:success => true, :data=>{aaaaaa: 3333, params: params}}
  end   
  
end

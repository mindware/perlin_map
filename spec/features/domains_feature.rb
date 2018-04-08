
describe "a region is available" do 
    include FeatureHelper

    before(:each) do 
      given_a_map_exists
    end

    context 'no generals are in the area' do
      it 'has an area' do 
        expect(@region).areas[0].class.to be.eq(Area)
      end
    end

end


package Property;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;
import java.util.List;

import org.apache.hadoop.io.Writable;

public class InfoWritable implements Writable {

	private String name;
	private String stars;
	private String businessId;
	private String latitude;
	private String longitude;
	private String reviewCount;
	private List<String> category;
	private String state;
	
	@Override
	public void readFields(DataInput in) throws IOException {
		// TODO Auto-generated method stub
		name = in.readUTF();  
		stars =  in.readUTF();
		businessId = in.readUTF();
	}

	@Override
	public void write(DataOutput out) throws IOException {
		// TODO Auto-generated method stub
		out.writeUTF(name);
		out.writeUTF(stars);
		out.writeUTF(businessId);
	}

	public void SetName(String name)
	{
		this.name = name;
	}
	
	public void SetStars(String stars)
	{
		this.stars = stars;
	}
	
	public void SetId(String businessId)
	{
		this.businessId = businessId;
	}
	
	public String GetName()
	{
		return name;
	}
	
	public String GetStars()
	{
		return stars;
	}
	
	public String GetBusinessId()
	{
		return businessId;
	}
}

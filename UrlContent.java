import java.util.*;
import java.io.*;
import java.net.*;
import javax.imageio.*;
import java.awt.image.BufferedImage;

public class UrlContent{
    public static void main(String[] args) {
        BufferedImage image = null;
        int year = 2015;
        
        // make 12 folders for each month
        for (int month = 1; month <= 12; month++) {
            File directory = new File(String.format("%02d", month));
            if (!directory.exists()){
                directory.mkdir();
            }
            
            Calendar mycal = new GregorianCalendar(year, month, 1);
            int daysInMonth = mycal.getActualMaximum(Calendar.DAY_OF_MONTH);
            
            for (int day = 1; day <= daysInMonth; day++) {
                try {
                    Date date = new Date(0, day, month, year);
                    URL url = new URL("https://www.ncdc.noaa.gov/gibbs/image/GRD-1/WV/" + date.toString());
                    System.out.println(url);
                    image = ImageIO.read(url);
        
                    ImageIO.write(image, "jpg", new File(String.format("%02d", month) + "/" + date.toString() + ".jpg"));
                } catch (IOException e) {
                	e.printStackTrace();
                }
            }
        }
    }
}
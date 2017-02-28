public class Date {
    int hour;
    int day;
    int month;
    int year;
    
    public Date(int hour, int day, int month, int year) {
        this.hour = hour;
        this.day = day;
        this.month = month;
        this.year = year;
    }
    
    @Override
    public String toString() {
        return String.format("%04d", year) + "-" + String.format("%02d", month) + "-" 
            + String.format("%02d", day) + "-" + String.format("%02d", hour);
    }
}
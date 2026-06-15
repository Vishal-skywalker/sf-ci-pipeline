public class GeneralException extends Exception {

    public Integer statusCode = 500;

    public GeneralException(String message, Integer code) {
        this.setMessage(message);
        statusCode = code;
    }
}
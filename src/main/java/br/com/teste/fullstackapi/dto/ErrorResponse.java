package br.com.teste.fullstackapi.dto;

import java.time.LocalDateTime;
import java.util.List;

public class ErrorResponse {

    private int statusCode;
    private String message;
    private List<String> details;
    private LocalDateTime timestamp;

    public ErrorResponse(int statusCode, String message, List<String> details) {
        this.statusCode = statusCode;
        this.message = message;
        this.details = details;
        this.timestamp = LocalDateTime.now();
    }
    
    // Getters e Setters
    public int getStatusCode() { return statusCode; }
    public void setStatusCode(int statusCode) { this.statusCode = statusCode; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public List<String> getDetails() { return details; }
    public void setDetails(List<String> details) { this.details = details; }
    public LocalDateTime getTimestamp() { return timestamp; }
    public void setTimestamp(LocalDateTime timestamp) { this.timestamp = timestamp; }
}
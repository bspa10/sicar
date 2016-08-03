package br.com.bsparaujo.datatype;

public abstract class DatatypeException extends RuntimeException {

    DatatypeException(String message) {
        super(message);
    }
}

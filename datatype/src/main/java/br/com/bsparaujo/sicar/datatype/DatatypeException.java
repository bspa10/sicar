package br.com.bsparaujo.sicar.datatype;

public abstract class DatatypeException extends RuntimeException {

    DatatypeException(String message) {
        super(message);
    }
}

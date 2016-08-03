package br.com.bsparaujo.datatype;

import org.junit.Assert;
import org.junit.Test;

public class EmailUnitTest {

    @Test
    public void criar_email_valido() throws Exception {
        Email.newEmail("email@fulanos.com");
        Email.newEmail("email@fulanos.com.br");
        Email email = Email.newEmail("email@fulanos.ca");

        Assert.assertEquals("email@fulanos.ca", email.getEndereco());
    }

    @Test(expected = EmailException.class)
    public void criar_nulo() throws Exception {
        Email.newEmail(null);
    }

    @Test(expected = EmailException.class)
    public void criar_com_string_vazia() throws Exception {
        Email.newEmail("");
    }

    @Test(expected = EmailException.class)
    public void criar_email_sem_host() throws Exception {
        Email.newEmail("email");
    }

    @Test(expected = EmailException.class)
    public void criar_email_com_host_incompleto() throws Exception {
        Email.newEmail("email@fulano");
    }

    @Test(expected = EmailException.class)
    public void criar_email_terminando_com_ponto() throws Exception {
        Email.newEmail("email@fulano.");
    }

    @Test(expected = EmailException.class)
    public void criar_email_com_caracteres_especiais_no_endereco() throws Exception {
        Email.newEmail("$$@fulano.com");
    }

    @Test(expected = EmailException.class)
    public void criar_email_sem_endereco() throws Exception {
        Email.newEmail("@fulano.com");
    }

}

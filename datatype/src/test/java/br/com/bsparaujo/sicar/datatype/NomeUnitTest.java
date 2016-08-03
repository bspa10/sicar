package br.com.bsparaujo.sicar.datatype;

import org.junit.Assert;
import org.junit.Test;

public class NomeUnitTest {

    @Test
    public void criar_nome_correto() {
        final Nome nome = Nome.newNome("José", "from Dual");

        Assert.assertEquals("José", nome.primeiro());
        Assert.assertEquals("from Dual", nome.sobrenome());
        Assert.assertEquals("José from Dual", nome.completo());
    }

    @Test(expected = NomeException.class)
    public void criar_nome_com_primeiro_nome_numerico() {
        Nome.newNome("primei9ro", "sobrenome");
    }

    @Test(expected = NomeException.class)
    public void criar_nome_com_sobrenome_numererico() {
        Nome.newNome("primeiro", "ult9imo");
    }

    @Test(expected = NomeException.class)
    public void criar_nome_com_sobrenome_vazio() {
        Nome.newNome("primeiro", "");
    }

    @Test(expected = NomeException.class)
    public void criar_nome_com_sobrenome_so_espacos() {
        Nome.newNome("primeiro", "    ");
    }

    @Test(expected = DatatypeException.class)
    public void criar_nome_com_primeiro_nome_so_espacos() {
        Nome.newNome("    ", "sobrenome");
    }

    @Test(expected = NomeException.class)
    public void criar_nome_com_primeiro_nome_vazio() {
        Nome.newNome("", "último");
    }

    @Test(expected = NomeException.class)
    public void criar_nome_com_sobrenome_nulo() {
        Nome.newNome("primeiro", null);
    }

    @Test(expected = NomeException.class)
    public void criar_nome_com_primeiro_nome_nulo() {
        Nome.newNome(null, "último");
    }

}

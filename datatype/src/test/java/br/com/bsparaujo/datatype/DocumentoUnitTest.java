package br.com.bsparaujo.datatype;

import org.junit.Assert;
import org.junit.Test;

public class DocumentoUnitTest {

    @Test
    public void cpf_criar_com_sucesso() throws Exception {
        final Documento documento = Documento.newDocumento(TipoDocumento.CPF, "00860493130");
        Assert.assertNotNull(documento);
        Assert.assertEquals("008.604.931-30", documento.formatado());
        Assert.assertEquals("00860493130", documento.semFormato());
        Assert.assertEquals(TipoDocumento.CPF, documento.getTipoDocumento());
    }

    @Test(expected = DocumentoException.class)
    public void cpf_criar_com_menos_de_11_caracteres() throws Exception {
        Documento.newDocumento(TipoDocumento.CPF, "0086049313");
    }

    @Test(expected = DocumentoException.class)
    public void cpf_criar_com_mais_de_11_caracteres() throws Exception {
        Documento.newDocumento(TipoDocumento.CPF, "0086049313030");
    }

    @Test(expected = DocumentoException.class)
    public void cpf_criar_nulo() throws Exception {
        Documento.newDocumento(TipoDocumento.CPF, null);
    }

    @Test(expected = DocumentoException.class)
    public void cpf_criar_com_string_vazia() throws Exception {
        Documento.newDocumento(TipoDocumento.CPF, "");
    }

    @Test
    public void cnpj_criar_com_sucesso() throws Exception {
        final Documento documento = Documento.newDocumento(TipoDocumento.CNPJ, "03766873000106");
        Assert.assertNotNull(documento);
        Assert.assertEquals("03.766.873/0001-06", documento.formatado());
    }

    @Test(expected = DocumentoException.class)
    public void cnpj_criar_com_menos_de_14_caracteres() throws Exception {
        Documento.newDocumento(TipoDocumento.CNPJ, "0376687300010");
    }

    @Test(expected = DocumentoException.class)
    public void cnpj_criar_com_mais_de_14_caracteres() throws Exception {
        Documento.newDocumento(TipoDocumento.CNPJ, "037668730001060");
    }

    @Test(expected = DocumentoException.class)
    public void cnpj_criar_nulo() throws Exception {
        Documento.newDocumento(TipoDocumento.CNPJ, null);
    }

    @Test(expected = DocumentoException.class)
    public void cnpj_criar_com_string_vazia() throws Exception {
        Documento.newDocumento(TipoDocumento.CNPJ, "");
    }

}

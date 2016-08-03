package br.com.bsparaujo.datatype;

import lombok.AccessLevel;
import lombok.EqualsAndHashCode;
import lombok.Getter;

@EqualsAndHashCode
public final class Documento {

    @Getter(AccessLevel.PUBLIC)
    private final TipoDocumento tipoDocumento;
    private final String documento;

    private Documento(final TipoDocumento tipoDocumento, final String documento) {
        if (!tipoDocumento.ehValido(documento)){
            throw new DocumentoException("O documento " + documento + " não é um " + tipoDocumento + " válido.");
        }

        this.tipoDocumento = tipoDocumento;
        this.documento = documento;
    }

    /**
     * Cria um novo documento.
     *
     * @param tipoDocumento Tipo de documento
     * @param documento Valor do documento
     * @return Documento que foi criado
     */
    public static Documento newDocumento(final TipoDocumento tipoDocumento, final String documento) {
        return new Documento(tipoDocumento, documento);
    }

    /**
    * Documento formatado para apresentação.
    *
    * @return Documento formatado para apresentação
    */
    public String formatado() {
        return tipoDocumento.formatar(this);
    }

    /**
     * Documento sem nenhuma formatação.
     * @return Documento sem nenhuma formatação
     */
    public String semFormato() {
        return documento;
    }

}

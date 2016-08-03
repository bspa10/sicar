package br.com.bsparaujo.framework.ddd;

import java.io.Serializable;

/**
 * Identifica que o registro não possuí uma identidade própria mas é apenas um agrupamento de dados.
 */
public interface ValueObject <T> extends Serializable {

    /**
     * Identifica se outro VO de mesmo tipo é igual a este.
     *
     * @param other Outro VO.
     * @return <code>true</code> se tiver os mesmos valores, <code>false</code> caso contrário
     */
    boolean sameValueAs(T other);

    /**
     * Cria uma cópia do VO em questão.
     *
     * @return Cópia do VO
     */
    T copy();

}

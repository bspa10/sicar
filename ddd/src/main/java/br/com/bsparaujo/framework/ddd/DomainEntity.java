package br.com.bsparaujo.framework.ddd;

import java.util.Optional;

/**
 * Objetos que possuem identidade e que são distinguidos por esta identidade e não apenas por suas características.
 *
 * <p>
 *     Obviamente, estamos falando de identitidade para o negócio. Al�m de atributos, Entities também podem ter comportamentos.
 * </p>
 */
public interface DomainEntity {

    /**
     * Obtém a identidade da entidade.
     */
    Optional<Long> identidade();

}

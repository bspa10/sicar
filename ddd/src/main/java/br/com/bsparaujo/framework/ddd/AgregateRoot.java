package br.com.bsparaujo.framework.ddd;

/**
 * Conjunto de entities agregadas por uma entity raiz.
 *
 * <p>
 *     Algumas {@link DomainEntity}s não possuem por si só um significado global no domínio; ao invés, elas só fazem sentido quando precedidas por um "pai".
 *
 *     <br>O AgragateRoot é então a raiz por onde as {@link DomainEntity}s filhas podem ser acessadas.
 * </p>
 */
public interface AgregateRoot {

}

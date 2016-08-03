package br.com.bsparaujo.framework.ddd;

/**
 * Um repositório representa uma forma de obter um {@link AgregateRoot} do local de armazenamento.
 *
 * <p>
 *     O conceito de repositório não tem relação com um repositório de dados.
 * </p>
 */
public interface DomainRepository<E extends DomainEntity> {

}

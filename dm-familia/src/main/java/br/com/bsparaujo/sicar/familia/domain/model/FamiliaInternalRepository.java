package br.com.bsparaujo.sicar.familia.domain.model;

import br.com.bsparaujo.sicar.familia.domain.repository.FamiliaRepository;

interface FamiliaInternalRepository extends FamiliaRepository {

    /**
     * Remove um membro da família.
     *
     *  <p>
     *      Se o membro que está sendo removído é o último, então a própria família será excluída.
     *  </p>
     * @param familia Família em questão
     * @param pessoa Pessoa que será removida
     */
    void removerMembro(Familia familia, Pessoa pessoa);

    /**
     * Adiciona um novo membro a família.
     *
     * @param familia Família em questão
     * @param pessoa Pessao que será adicionada à família
     */
    void adicionarMembro(Familia familia, Pessoa pessoa);

    /**
     * Persiste as alterações da família
     *
     * @param familia Família que será persistida
     */
    void salvar(Familia familia);
}

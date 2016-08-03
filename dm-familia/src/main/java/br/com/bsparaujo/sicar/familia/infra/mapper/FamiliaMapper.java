package br.com.bsparaujo.sicar.familia.infra.mapper;

import br.com.bsparaujo.datatype.Email;
import br.com.bsparaujo.sicar.familia.domain.model.Familia;
import br.com.bsparaujo.sicar.infra.mapper.DataMapper;

import java.util.List;
import java.util.Optional;

public interface FamiliaMapper extends DataMapper<Familia> {

    List<Familia> listarFamilias(final Email email);

    Optional<Familia> obterPorCabeca(final Email email);

    void removerMembro(final long familiaId, final Email email);

    void adicionarMembro(final long familiaId, final Email email);
}

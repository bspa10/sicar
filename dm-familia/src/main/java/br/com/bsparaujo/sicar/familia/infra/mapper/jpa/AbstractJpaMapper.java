package br.com.bsparaujo.sicar.familia.infra.mapper.jpa;

import br.com.bsparaujo.datatype.Documento;
import br.com.bsparaujo.datatype.Email;
import br.com.bsparaujo.datatype.Nome;
import br.com.bsparaujo.sicar.familia.domain.model.Familia;
import br.com.bsparaujo.sicar.familia.domain.model.Pessoa;
import org.springframework.util.ReflectionUtils;

import java.lang.reflect.Method;

abstract class AbstractJpaMapper {

    Pessoa fromEntity(PessoaEntity entity) {
        return Pessoa.of(
                Documento.newDocumento(entity.getTipoDocumento(), entity.getDocumento()),
                Nome.newNome(entity.getNome(), entity.getSobrenome()),
                Email.newEmail(entity.getEmail())
        );
    }

    void configurarIdentidade(Familia familia, long identidade) {
        final Method method = ReflectionUtils.findMethod(Familia.class, "setId", Long.class);
        ReflectionUtils.makeAccessible(method);
        ReflectionUtils.invokeMethod(method, familia, identidade);
    }

    void configurarIdentidade(Pessoa pessoa, long identidade) {
        final Method method = ReflectionUtils.findMethod(Pessoa.class, "setId", Long.class);
        ReflectionUtils.makeAccessible(method);
        ReflectionUtils.invokeMethod(method, pessoa, identidade);
    }
}

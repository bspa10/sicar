package br.com.bsparaujo.sicar.familia.infra.mapper.jpa;

import br.com.bsparaujo.datatype.TipoDocumento;

import javax.persistence.AttributeConverter;
import javax.persistence.Converter;

@Converter
public class TipoDocumentoConverter implements AttributeConverter<TipoDocumento, Integer> {

    @Override
    public Integer convertToDatabaseColumn(TipoDocumento attribute) {
        return attribute.value();
    }

    @Override
    public TipoDocumento convertToEntityAttribute(Integer dbData) {
        return TipoDocumento.valueOf(dbData);
    }
}
